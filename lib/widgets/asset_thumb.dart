import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Square thumbnail of a gallery asset, loaded lazily.
class AssetThumb extends StatefulWidget {
  const AssetThumb({super.key, required this.asset, this.size = 250});

  final AssetEntity asset;
  final int size;

  @override
  State<AssetThumb> createState() => _AssetThumbState();
}

class _AssetThumbState extends State<AssetThumb> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(AssetThumb old) {
    super.didUpdateWidget(old);
    if (old.asset.id != widget.asset.id) _future = _load();
  }

  Future<Uint8List?> _load() => widget.asset.thumbnailDataWithSize(
    ThumbnailSize.square(widget.size),
    quality: 80,
  );

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: data == null
              ? ColoredBox(key: const ValueKey('ph'), color: bg)
              : Image.memory(
                  data,
                  key: const ValueKey('img'),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
        );
      },
    );
  }
}
