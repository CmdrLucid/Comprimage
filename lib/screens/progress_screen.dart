import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../l10n/l10n_ext.dart';
import '../models/compression_settings.dart';
import '../services/compression_service.dart';

/// Runs the batch and pops with the list of results.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.assets,
    required this.settings,
    this.service,
  });

  final List<AssetEntity> assets;
  final CompressionSettings settings;
  final CompressionService? service;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final CancelToken _cancel = CancelToken();
  CompressionProgress? _progress;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final service = widget.service ?? CompressionService();
    final results = await service.run(
      widget.assets,
      widget.settings,
      cancel: _cancel,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );
    if (mounted) Navigator.of(context).pop(results);
  }

  Future<void> _confirmCancel() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cancelDialogTitle),
        content: Text(l.cancelDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.keepGoing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
    if (ok == true) {
      _cancel.cancel();
      setState(() => _cancelling = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final p = _progress;
    final total = widget.assets.length;
    final fraction = p == null ? 0.0 : (p.current - 1) / total;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_cancelling) _confirmCancel();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.progressTitle)),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: fraction),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, v, _) => CircularProgressIndicator(
                            value: v,
                            strokeWidth: 10,
                            strokeCap: StrokeCap.round,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      Text(
                        '${p?.current ?? 0} / $total',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _cancelling
                      ? l.cancelling
                      : l.progressOf(p?.current ?? 0, total),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (p != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _cancelling ? null : _confirmCancel,
                  icon: const Icon(Icons.close),
                  label: Text(l.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
