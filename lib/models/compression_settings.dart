import 'preset.dart';

/// Immutable settings for one compression run.
class CompressionSettings {
  const CompressionSettings({
    this.format = OutputFormat.jpeg,
    this.quality = 75,
    this.maxEdge = 1920,
    this.targetBytes,
    this.stripMetadata = true,
    this.saveMode = SaveMode.copy,
  });

  /// Settings initialised from a [Preset].
  factory CompressionSettings.fromPreset(Preset preset) =>
      const CompressionSettings().applyPreset(preset);

  final OutputFormat format;

  /// 10..100.
  final int quality;

  /// Longest edge in px; `null` keeps the original resolution.
  final int? maxEdge;

  /// Optional target file size in bytes per image.
  final int? targetBytes;

  /// Remove EXIF/GPS data.
  ///
  /// Limitation: flutter_image_compress only honours `keepExif` for JPEG
  /// output. WebP output never carries EXIF/GPS data (it is always dropped),
  /// so with WebP the metadata cannot be preserved even if this is `false`.
  final bool stripMetadata;

  final SaveMode saveMode;

  CompressionSettings applyPreset(Preset preset) =>
      copyWith(quality: preset.quality, maxEdge: () => preset.maxEdge);

  /// The preset whose values equal the current quality and edge, if any.
  Preset? get matchingPreset {
    for (final p in Preset.values) {
      if (p.quality == quality && p.maxEdge == maxEdge) return p;
    }
    return null;
  }

  CompressionSettings copyWith({
    OutputFormat? format,
    int? quality,
    int? Function()? maxEdge,
    int? Function()? targetBytes,
    bool? stripMetadata,
    SaveMode? saveMode,
  }) {
    return CompressionSettings(
      format: format ?? this.format,
      quality: (quality ?? this.quality).clamp(kMinQuality, kMaxQuality),
      maxEdge: maxEdge != null ? maxEdge() : this.maxEdge,
      targetBytes: targetBytes != null ? targetBytes() : this.targetBytes,
      stripMetadata: stripMetadata ?? this.stripMetadata,
      saveMode: saveMode ?? this.saveMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CompressionSettings &&
      other.format == format &&
      other.quality == quality &&
      other.maxEdge == maxEdge &&
      other.targetBytes == targetBytes &&
      other.stripMetadata == stripMetadata &&
      other.saveMode == saveMode;

  @override
  int get hashCode => Object.hash(
    format,
    quality,
    maxEdge,
    targetBytes,
    stripMetadata,
    saveMode,
  );
}
