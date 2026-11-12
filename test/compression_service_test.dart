import 'dart:typed_data';

import 'package:comprimage/models/preset.dart';
import 'package:comprimage/services/compression_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake encoder: size shrinks with quality and with the square of the edge.
CompressFn fakeCompress(
  List<(int, int?)> calls, {
  int fullEdge = 4000,
  int sizeAtQ100 = 1000000,
}) {
  return (q, edge) async {
    calls.add((q, edge));
    final e = (edge ?? fullEdge) / fullEdge;
    return Uint8List((sizeAtQ100 * (q / 100) * e * e).round());
  };
}

void main() {
  group('compressMinSize', () {
    // Mirrors flutter_image_compress on Android: it scales the raw (not EXIF
    // rotated) bitmap by max(1, min(w / minW, h / minH)).
    (int, int) simulate(int rawW, int rawH, ({int width, int height}) m) {
      final scale = [
        1.0,
        [rawW / m.width, rawH / m.height].reduce((a, b) => a < b ? a : b),
      ].reduce((a, b) => a > b ? a : b);
      return ((rawW / scale).round(), (rawH / scale).round());
    }

    test('caps the longest edge for landscape and portrait input', () {
      expect(simulate(4000, 3000, compressMinSize(4000, 3000, 2000)), (
        2000,
        1500,
      ));
      expect(simulate(3000, 4000, compressMinSize(3000, 4000, 2000)), (
        1500,
        2000,
      ));
    });

    test('works when dimensions are EXIF rotated relative to the file', () {
      // File is stored as 4000x3000, asset reports 3000x4000 (rotated).
      expect(simulate(4000, 3000, compressMinSize(3000, 4000, 2000)), (
        2000,
        1500,
      ));
    });

    test('keeps the size without a limit, below it, or without dimensions', () {
      expect(simulate(4000, 3000, compressMinSize(4000, 3000, null)), (
        4000,
        3000,
      ));
      expect(simulate(1000, 800, compressMinSize(1000, 800, 1920)), (
        1000,
        800,
      ));
      expect(compressMinSize(0, 0, 2000), (width: 1, height: 1));
    });
  });

  group('targetDimensions', () {
    test('keeps size when no limit or already small', () {
      expect(targetDimensions(4000, 3000, null), (width: 4000, height: 3000));
      expect(targetDimensions(1000, 800, 1920), (width: 1000, height: 800));
    });

    test('caps longest edge, keeps aspect ratio', () {
      expect(targetDimensions(4000, 3000, 2000), (width: 2000, height: 1500));
      expect(targetDimensions(3000, 4000, 2000), (width: 1500, height: 2000));
    });
  });

  group('buildOutputName', () {
    test('copy gets suffix and new extension', () {
      expect(
        buildOutputName('IMG_1.JPG', OutputFormat.webp, asCopy: true),
        'IMG_1_comprimage.webp',
      );
    });
    test('replace keeps base name', () {
      expect(
        buildOutputName('a.b.png', OutputFormat.jpeg, asCopy: false),
        'a.b.jpg',
      );
      expect(buildOutputName('', OutputFormat.jpeg, asCopy: false), 'Foto.jpg');
    });
  });

  group('searchTargetSize', () {
    test('returns requested quality directly when it already fits', () async {
      final calls = <(int, int?)>[];
      final r = await searchTargetSize(
        compress: fakeCompress(calls),
        targetBytes: 900000,
        maxQuality: 80,
        startEdge: 4000,
      );
      expect(r.reachedTarget, isTrue);
      expect(r.quality, 80);
      expect(calls.length, 1);
    });

    test('finds highest fitting quality within iteration budget', () async {
      final calls = <(int, int?)>[];
      final r = await searchTargetSize(
        compress: fakeCompress(calls),
        targetBytes: 500000, // fits up to q=50
        maxQuality: 95,
        startEdge: 4000,
      );
      expect(r.reachedTarget, isTrue);
      expect(r.bytes.length, lessThanOrEqualTo(500000));
      expect(r.quality, inInclusiveRange(48, 50));
      expect(r.maxEdge, 4000);
      expect(calls.length, lessThanOrEqualTo(1 + 6));
    });

    test('downscales when minimum quality is not enough', () async {
      final calls = <(int, int?)>[];
      final r = await searchTargetSize(
        compress: fakeCompress(calls),
        targetBytes: 20000, // q=10 at full size is 100000
        maxQuality: 90,
        startEdge: 4000,
      );
      expect(r.reachedTarget, isTrue);
      expect(r.bytes.length, lessThanOrEqualTo(20000));
      expect(r.maxEdge, lessThan(4000));
    });

    test('reports failure and returns smallest when impossible', () async {
      final calls = <(int, int?)>[];
      final r = await searchTargetSize(
        compress: fakeCompress(calls),
        targetBytes: 10, // impossible
        maxQuality: 90,
        startEdge: 4000,
      );
      expect(r.reachedTarget, isFalse);
      final smallest = calls
          .map(
            (c) =>
                (1000000 *
                        (c.$1 / 100) *
                        ((c.$2 ?? 4000) / 4000) *
                        ((c.$2 ?? 4000) / 4000))
                    .round(),
          )
          .reduce((a, b) => a < b ? a : b);
      expect(r.bytes.length, smallest);
    });

    test('without known edge it cannot downscale and stops', () async {
      final calls = <(int, int?)>[];
      final r = await searchTargetSize(
        compress: fakeCompress(calls),
        targetBytes: 20000,
        maxQuality: 90,
        startEdge: null,
      );
      expect(r.reachedTarget, isFalse);
      expect(calls.every((c) => c.$2 == null), isTrue);
    });
  });
}
