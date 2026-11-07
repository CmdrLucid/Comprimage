import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../models/compression_result.dart';

/// Before/after slider: drag the handle to reveal original vs compressed.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key, required this.result});

  final CompressionResult result;

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  double _pos = 0.5;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = widget.result;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.compareTitle)),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => setState(
                    () => _pos = (_pos + d.delta.dx / w).clamp(0.0, 1.0),
                  ),
                  onTapDown: (d) => setState(
                    () => _pos = (d.localPosition.dx / w).clamp(0.0, 1.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(r.compressedPath!), fit: BoxFit.contain),
                      ClipRect(
                        clipper: _LeftClipper(_pos),
                        child: Image.file(
                          File(r.originalPath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: w * _pos - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 3, color: scheme.primary),
                      ),
                      Positioned(
                        left: w * _pos - 22,
                        top: c.maxHeight / 2 - 22,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.compare_arrows,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _Tag(
                          '${l.before} · ${context.bytes(r.originalBytes)}',
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: _Tag(
                          '${l.after} · ${context.bytes(r.compressedBytes)}',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.fraction != fraction;
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
