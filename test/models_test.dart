import 'package:comprimage/models/compression_result.dart';
import 'package:comprimage/models/compression_settings.dart';
import 'package:comprimage/models/formatting.dart';
import 'package:comprimage/models/preset.dart';
import 'package:flutter_test/flutter_test.dart';

CompressionResult _r(
  int orig,
  int comp, [
  ResultStatus s = ResultStatus.done,
]) => CompressionResult(
  assetId: 'a',
  name: 'n',
  originalBytes: orig,
  compressedBytes: comp,
  status: s,
);

void main() {
  group('presets', () {
    test('apply quality and edge', () {
      final s = CompressionSettings.fromPreset(Preset.small);
      expect(s.quality, 55);
      expect(s.maxEdge, 1280);
      expect(s.matchingPreset, Preset.small);
    });

    test('preset values are within bounds and edges are offered', () {
      for (final p in Preset.values) {
        expect(p.quality, inInclusiveRange(kMinQuality, kMaxQuality));
        expect(kMaxEdgeOptions, contains(p.maxEdge));
      }
    });

    test('manual change clears matching preset', () {
      final s = CompressionSettings.fromPreset(Preset.medium)
          .copyWith(quality: 70);
      expect(s.matchingPreset, isNull);
    });

    test('quality is clamped and defaults are sane', () {
      const d = CompressionSettings();
      expect(d.stripMetadata, isTrue);
      expect(d.saveMode, SaveMode.copy);
      expect(d.copyWith(quality: 500).quality, 100);
      expect(d.copyWith(quality: 1).quality, 10);
    });

    test('copyWith can set and clear nullable fields', () {
      final s = const CompressionSettings().copyWith(targetBytes: () => 1000);
      expect(s.targetBytes, 1000);
      expect(s.copyWith(targetBytes: () => null).targetBytes, isNull);
      expect(s.copyWith(maxEdge: () => null).maxEdge, isNull);
    });
  });

  group('formatting', () {
    test('formatBytes english', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(1024 * 1024), '1 MB');
      expect(formatBytes((2.5 * 1024 * 1024).round()), '2.5 MB');
    });

    test('formatBytes german uses decimal comma', () {
      expect(formatBytes(1536, decimalComma: true), '1,5 KB');
      expect(formatBytes(-1536, decimalComma: true), '-1,5 KB');
    });

    test('formatPercent', () => expect(formatPercent(42.4), '42 %'));

    test('parseTargetBytes', () {
      expect(parseTargetBytes('500', megabytes: false), 500 * 1024);
      expect(
        parseTargetBytes('1,5', megabytes: true),
        (1.5 * 1024 * 1024).round(),
      );
      expect(
        parseTargetBytes('1.5', megabytes: true),
        (1.5 * 1024 * 1024).round(),
      );
      expect(parseTargetBytes('', megabytes: false), isNull);
      expect(parseTargetBytes('abc', megabytes: false), isNull);
      expect(parseTargetBytes('0', megabytes: true), isNull);
      expect(parseTargetBytes('-3', megabytes: true), isNull);
    });
  });

  group('results', () {
    test('savings per result', () {
      final r = _r(1000, 250);
      expect(r.savedBytes, 750);
      expect(r.savedPercent, 75);
    });

    test('skipped and failed count as zero savings', () {
      expect(_r(1000, 1200, ResultStatus.skippedNotSmaller).savedBytes, 0);
      expect(_r(0, 0, ResultStatus.failed).savedPercent, 0);
    });

    test('summary aggregates only successful results', () {
      final s = ResultSummary([
        _r(1000, 500),
        _r(3000, 1000),
        _r(500, 600, ResultStatus.skippedNotSmaller),
        _r(0, 0, ResultStatus.failed),
      ]);
      expect(s.total, 4);
      expect(s.done, 2);
      expect(s.skipped, 1);
      expect(s.failed, 1);
      expect(s.savedBytes, 2500);
      expect(s.savedPercent, closeTo(62.5, 0.001));
    });

    test('empty summary has no division by zero', () {
      expect(ResultSummary([]).savedPercent, 0);
    });
  });
}
