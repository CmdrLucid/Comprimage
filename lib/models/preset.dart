/// Output container/codec for compressed images.
enum OutputFormat {
  jpeg('JPEG', 'jpg'),
  webp('WebP', 'webp');

  const OutputFormat(this.label, this.extension);
  final String label;
  final String extension;
}

/// How compressed images are stored.
enum SaveMode {
  /// Save as a new file in Pictures/Comprimage, keep originals.
  copy,

  /// Save compressed image, then delete the original (system confirmation).
  replace,
}

/// Allowed maximum edge lengths in pixels (`null` = original size).
const List<int?> kMaxEdgeOptions = [null, 3840, 2560, 1920, 1280];

/// Quality bounds exposed in the UI.
const int kMinQuality = 10;
const int kMaxQuality = 100;

/// Ready-made combinations of quality and maximum edge length.
enum Preset {
  small(55, 1280),
  medium(75, 1920),
  high(90, 2560);

  const Preset(this.quality, this.maxEdge);
  final int quality;
  final int? maxEdge;
}
