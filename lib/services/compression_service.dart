import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/compression_result.dart';
import '../models/compression_settings.dart';
import '../models/preset.dart';

// ---------------------------------------------------------------------------
// Pure, unit-testable logic
// ---------------------------------------------------------------------------

/// Compresses an image with the given [quality] and [maxEdge] (longest edge in
/// px, `null` = original size). Injected so the search can be tested.
typedef CompressFn = Future<Uint8List> Function(int quality, int? maxEdge);

/// Result of [searchTargetSize].
class TargetSearchResult {
  const TargetSearchResult({
    required this.bytes,
    required this.quality,
    required this.maxEdge,
    required this.reachedTarget,
    required this.attempts,
  });

  final Uint8List bytes;
  final int quality;
  final int? maxEdge;
  final bool reachedTarget;
  final int attempts;
}

/// Computes the output dimensions so that the longest edge is at most
/// [maxEdge]. Never upscales. Returns the input size when [maxEdge] is null.
({int width, int height}) targetDimensions(
  int width,
  int height,
  int? maxEdge,
) {
  if (maxEdge == null || maxEdge <= 0) return (width: width, height: height);
  final longest = math.max(width, height);
  if (longest <= maxEdge) return (width: width, height: height);
  final scale = maxEdge / longest;
  return (
    width: math.max(1, (width * scale).round()),
    height: math.max(1, (height * scale).round()),
  );
}

/// Finds the highest quality (<= [maxQuality]) whose output is at most
/// [targetBytes], using a binary search with at most [maxIterations] probes
/// after the initial attempt at [maxQuality].
///
/// If even [minQuality] does not fit, the image is additionally downscaled
/// (up to [maxDownscaleSteps] times, starting from [startEdge], the image's
/// longest edge) until the target is met. If the target cannot be met, the
/// smallest result found is returned with `reachedTarget == false`.
Future<TargetSearchResult> searchTargetSize({
  required CompressFn compress,
  required int targetBytes,
  required int maxQuality,
  required int? startEdge,
  int minQuality = kMinQuality,
  int maxIterations = 6,
  int maxDownscaleSteps = 4,
  int minEdge = 320,
}) async {
  var attempts = 0;
  Uint8List? bestFit;
  var bestFitQuality = minQuality;
  Uint8List? smallest;
  var smallestQuality = minQuality;
  int? smallestEdge = startEdge;

  void track(Uint8List data, int q, int? edge) {
    if (smallest == null || data.length < smallest!.length) {
      smallest = data;
      smallestQuality = q;
      smallestEdge = edge;
    }
  }

  Future<Uint8List> probe(int q, int? edge) async {
    attempts++;
    final d = await compress(q, edge);
    track(d, q, edge);
    return d;
  }

  // 1. Is the requested quality already small enough?
  final top = await probe(maxQuality, startEdge);
  if (top.length <= targetBytes) {
    return TargetSearchResult(
      bytes: top,
      quality: maxQuality,
      maxEdge: startEdge,
      reachedTarget: true,
      attempts: attempts,
    );
  }

  // 2. Binary search in [minQuality, maxQuality - 1].
  var lo = minQuality;
  var hi = maxQuality - 1;
  var iterations = 0;
  // Probe the lowest quality first when the range is non-trivial: if it does
  // not fit, no further quality search is needed and we go straight to
  // downscaling. This costs one iteration.
  if (hi >= lo) {
    final low = await probe(lo, startEdge);
    iterations++;
    if (low.length <= targetBytes) {
      bestFit = low;
      bestFitQuality = lo;
      lo = lo + 1;
    } else {
      hi = lo - 1; // nothing fits at this edge
    }
  }
  while (lo <= hi && iterations < maxIterations) {
    final mid = (lo + hi) ~/ 2;
    final d = await probe(mid, startEdge);
    iterations++;
    if (d.length <= targetBytes) {
      bestFit = d;
      bestFitQuality = mid;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  if (bestFit != null) {
    return TargetSearchResult(
      bytes: bestFit,
      quality: bestFitQuality,
      maxEdge: startEdge,
      reachedTarget: true,
      attempts: attempts,
    );
  }

  // 3. Minimum quality is not enough: downscale.
  var edge = startEdge;
  var lastSize = smallest!.length;
  for (var step = 0; step < maxDownscaleSteps; step++) {
    if (edge == null) break; // unknown resolution: cannot downscale
    final factor = (math.sqrt(targetBytes / lastSize) * 0.9)
        .clamp(0.3, 0.9)
        .toDouble();
    final next = math.max(minEdge, (edge * factor).round());
    if (next >= edge) break;
    edge = next;
    // Mid-range quality first (looks better than q=10 at the same size), then
    // the minimum quality as last resort for this edge.
    final q = math.max(minQuality, math.min(maxQuality, 50));
    var d = await probe(q, edge);
    if (d.length <= targetBytes) {
      return TargetSearchResult(
        bytes: d,
        quality: q,
        maxEdge: edge,
        reachedTarget: true,
        attempts: attempts,
      );
    }
    if (q != minQuality) {
      d = await probe(minQuality, edge);
      if (d.length <= targetBytes) {
        return TargetSearchResult(
          bytes: d,
          quality: minQuality,
          maxEdge: edge,
          reachedTarget: true,
          attempts: attempts,
        );
      }
    }
    lastSize = d.length;
    if (edge <= minEdge) break;
  }

  return TargetSearchResult(
    bytes: smallest!,
    quality: smallestQuality,
    maxEdge: smallestEdge,
    reachedTarget: false,
    attempts: attempts,
  );
}

/// Output file name (without directory) for a given source title.
String buildOutputName(
  String sourceTitle,
  OutputFormat format, {
  required bool asCopy,
}) {
  final dot = sourceTitle.lastIndexOf('.');
  final base = dot > 0 ? sourceTitle.substring(0, dot) : sourceTitle;
  final name = base.isEmpty ? 'Foto' : base;
  return asCopy
      ? '${name}_comprimage.${format.extension}'
      : '$name.${format.extension}';
}

// ---------------------------------------------------------------------------
// Platform-bound service
// ---------------------------------------------------------------------------

/// Cooperative cancellation flag.
class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class CompressionProgress {
  const CompressionProgress(this.current, this.total, this.name);
  final int current; // 1-based index of the photo being processed
  final int total;
  final String name;
}

/// Default relative path for saved copies.
const String kOutputRelativePath = 'Pictures/Comprimage';

class CompressionService {
  CompressionService({
    this.saveImage = _defaultSave,
    this.deleteAssets = _defaultDelete,
  });

  /// Injectable for tests/mocking.
  final Future<AssetEntity> Function(
    Uint8List data, {
    required String filename,
    required String title,
    required String relativePath,
    DateTime? creationDate,
  })
  saveImage;
  final Future<List<String>> Function(List<String> ids) deleteAssets;

  static Future<AssetEntity> _defaultSave(
    Uint8List data, {
    required String filename,
    required String title,
    required String relativePath,
    DateTime? creationDate,
  }) {
    return PhotoManager.editor.saveImage(
      data,
      filename: filename,
      title: title,
      relativePath: relativePath,
      creationDate: creationDate,
    );
  }

  static Future<List<String>> _defaultDelete(List<String> ids) =>
      PhotoManager.editor.deleteWithIds(ids);

  Future<Directory> _workDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/comprimage_run');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Removes temporary files of previous runs.
  Future<void> clearTemp() async {
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/comprimage_run');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  /// Processes [assets] strictly sequentially (avoids OOM).
  ///
  /// In replace mode, originals are deleted in a single batch at the end so
  /// that Android shows only one system confirmation dialog.
  Future<List<CompressionResult>> run(
    List<AssetEntity> assets,
    CompressionSettings settings, {
    void Function(CompressionProgress)? onProgress,
    CancelToken? cancel,
  }) async {
    await clearTemp();
    final dir = await _workDir();
    final results = <CompressionResult>[];

    for (var i = 0; i < assets.length; i++) {
      if (cancel?.isCancelled ?? false) break;
      final asset = assets[i];
      final name = (await asset.titleAsync);
      onProgress?.call(CompressionProgress(i + 1, assets.length, name));
      try {
        results.add(await _processOne(asset, name, settings, dir, i));
      } catch (e) {
        results.add(
          CompressionResult(
            assetId: asset.id,
            name: name,
            originalBytes: 0,
            compressedBytes: 0,
            status: ResultStatus.failed,
            error: e.toString(),
          ),
        );
      }
    }

    if (settings.saveMode == SaveMode.replace) {
      return _deleteOriginals(results);
    }
    return results;
  }

  Future<List<CompressionResult>> _deleteOriginals(
    List<CompressionResult> results,
  ) async {
    final ids = results.where((r) => r.isDone).map((r) => r.assetId).toList();
    if (ids.isEmpty) return results;
    List<String> deleted = const [];
    try {
      deleted = await deleteAssets(ids);
    } catch (_) {
      // User declined or platform error: keep both files.
    }
    final set = deleted.toSet();
    return [
      for (final r in results)
        set.contains(r.assetId) ? r.copyWith(originalDeleted: true) : r,
    ];
  }

  Future<CompressionResult> _processOne(
    AssetEntity asset,
    String name,
    CompressionSettings s,
    Directory dir,
    int index,
  ) async {
    final file = await asset.originFile;
    if (file == null) {
      throw StateError('File not readable');
    }
    final originalSize = await file.length();

    final width = asset.orientatedWidth;
    final height = asset.orientatedHeight;
    final hasDims = width > 0 && height > 0;
    final longest = hasDims ? math.max(width, height) : null;
    // Only pass an edge limit if it actually shrinks the image.
    int? startEdge = s.maxEdge;
    if (startEdge != null && longest != null && longest <= startEdge) {
      startEdge = longest;
    }

    Future<Uint8List> compress(int quality, int? edge) async {
      var minW = 1;
      var minH = 1;
      if (hasDims) {
        final d = targetDimensions(width, height, edge);
        minW = d.width;
        minH = d.height;
      } else if (edge != null) {
        minW = edge;
        minH = edge;
      }
      // flutter_image_compress scales so the image is at least minWidth x
      // minHeight while keeping the aspect ratio; passing the exact target
      // dimensions therefore caps the longest edge.
      final data = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: minW,
        minHeight: minH,
        quality: quality,
        format: s.format == OutputFormat.webp
            ? CompressFormat.webp
            : CompressFormat.jpeg,
        // keepExif only has an effect for JPEG output; WebP output never
        // contains EXIF/GPS in flutter_image_compress.
        keepExif: !s.stripMetadata,
      );
      if (data == null) throw StateError('Compression failed');
      return data;
    }

    Uint8List bytes;
    bool? targetReached;
    if (s.targetBytes != null) {
      final r = await searchTargetSize(
        compress: compress,
        targetBytes: s.targetBytes!,
        maxQuality: s.quality,
        startEdge: startEdge ?? longest,
      );
      bytes = r.bytes;
      targetReached = r.reachedTarget;
    } else {
      bytes = await compress(s.quality, startEdge);
    }

    if (bytes.length >= originalSize) {
      return CompressionResult(
        assetId: asset.id,
        name: name,
        originalBytes: originalSize,
        compressedBytes: bytes.length,
        status: ResultStatus.skippedNotSmaller,
        targetReached: targetReached,
      );
    }

    final asCopy = s.saveMode == SaveMode.copy;
    final outName = buildOutputName(name, s.format, asCopy: asCopy);
    final saved = await saveImage(
      bytes,
      filename: outName,
      title: outName.substring(0, outName.lastIndexOf('.')),
      relativePath: asCopy
          ? kOutputRelativePath
          : (asset.relativePath ?? kOutputRelativePath),
      creationDate: asset.createDateTime,
    );

    // Temp copies for the before/after view (originals may be deleted).
    final origCopy = File('${dir.path}/${index}_orig_${_safe(name)}');
    await file.copy(origCopy.path);
    final compCopy = File('${dir.path}/${index}_comp.${s.format.extension}');
    await compCopy.writeAsBytes(bytes, flush: true);

    return CompressionResult(
      assetId: asset.id,
      name: name,
      originalBytes: originalSize,
      compressedBytes: bytes.length,
      status: ResultStatus.done,
      originalPath: origCopy.path,
      compressedPath: compCopy.path,
      savedAssetId: saved.id,
      targetReached: targetReached,
    );
  }

  static String _safe(String n) =>
      n.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
