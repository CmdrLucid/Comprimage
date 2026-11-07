/// Outcome of processing one photo.
enum ResultStatus {
  /// Compressed and saved.
  done,

  /// Compressed result was not smaller than the original; nothing saved.
  skippedNotSmaller,

  /// Processing failed.
  failed,
}

class CompressionResult {
  const CompressionResult({
    required this.assetId,
    required this.name,
    required this.originalBytes,
    required this.compressedBytes,
    required this.status,
    this.originalPath,
    this.compressedPath,
    this.savedAssetId,
    this.originalDeleted = false,
    this.targetReached,
    this.error,
  });

  final String assetId;
  final String name;
  final int originalBytes;

  /// Size of the compressed data (0 when failed).
  final int compressedBytes;
  final ResultStatus status;

  /// Temporary file copies used for the before/after comparison.
  final String? originalPath;
  final String? compressedPath;

  /// Id of the newly saved gallery asset.
  final String? savedAssetId;

  /// Whether the original was deleted from the gallery.
  final bool originalDeleted;

  /// `null` when no target size was requested.
  final bool? targetReached;
  final String? error;

  bool get isDone => status == ResultStatus.done;

  /// Bytes saved (only counted for successfully saved photos).
  int get savedBytes => isDone ? originalBytes - compressedBytes : 0;

  /// Savings in percent (0..100), 0 when not applicable.
  double get savedPercent =>
      (isDone && originalBytes > 0) ? savedBytes / originalBytes * 100 : 0;

  CompressionResult copyWith({bool? originalDeleted}) => CompressionResult(
    assetId: assetId,
    name: name,
    originalBytes: originalBytes,
    compressedBytes: compressedBytes,
    status: status,
    originalPath: originalPath,
    compressedPath: compressedPath,
    savedAssetId: savedAssetId,
    originalDeleted: originalDeleted ?? this.originalDeleted,
    targetReached: targetReached,
    error: error,
  );
}

/// Aggregated numbers over a list of results.
class ResultSummary {
  ResultSummary(List<CompressionResult> results)
    : total = results.length,
      done = results.where((r) => r.isDone).length,
      skipped = results
          .where((r) => r.status == ResultStatus.skippedNotSmaller)
          .length,
      failed = results.where((r) => r.status == ResultStatus.failed).length,
      originalBytes = results
          .where((r) => r.isDone)
          .fold(0, (a, r) => a + r.originalBytes),
      compressedBytes = results
          .where((r) => r.isDone)
          .fold(0, (a, r) => a + r.compressedBytes);

  final int total;
  final int done;
  final int skipped;
  final int failed;
  final int originalBytes;
  final int compressedBytes;

  int get savedBytes => originalBytes - compressedBytes;
  double get savedPercent =>
      originalBytes > 0 ? savedBytes / originalBytes * 100 : 0;
}
