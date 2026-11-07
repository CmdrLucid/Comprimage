/// Formats a byte count, e.g. `1.5 MB` (or `1,5 MB` when [decimalComma]).
String formatBytes(int bytes, {bool decimalComma = false}) {
  final negative = bytes < 0;
  final b = bytes.abs();
  String out;
  if (b < 1024) {
    out = '$b B';
  } else if (b < 1024 * 1024) {
    out = '${_fmt(b / 1024, decimalComma)} KB';
  } else if (b < 1024 * 1024 * 1024) {
    out = '${_fmt(b / (1024 * 1024), decimalComma)} MB';
  } else {
    out = '${_fmt(b / (1024 * 1024 * 1024), decimalComma)} GB';
  }
  return negative ? '-$out' : out;
}

String _fmt(double v, bool comma) {
  final s = v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  final trimmed = s.replaceFirst(RegExp(r'\.0$'), '');
  return comma ? trimmed.replaceAll('.', ',') : trimmed;
}

/// Formats a percentage, e.g. `42 %`.
String formatPercent(double p) => '${p.round()} %';

/// Parses user input such as `500` or `1,5` / `1.5` into bytes for the unit.
/// Returns `null` for empty, invalid or non-positive input.
int? parseTargetBytes(String input, {required bool megabytes}) {
  final cleaned = input.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final v = double.tryParse(cleaned);
  if (v == null || v <= 0 || v.isNaN || v.isInfinite) return null;
  final factor = megabytes ? 1024 * 1024 : 1024;
  final bytes = (v * factor).round();
  return bytes <= 0 ? null : bytes;
}
