import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/compression_result.dart';
import '../models/formatting.dart';
import 'compare_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.results});

  final List<CompressionResult> results;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final sum = ResultSummary(results);
    return Scaffold(
      appBar: AppBar(title: Text(l.resultsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.totalSaved(context.bytes(sum.savedBytes)),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.totalSavedDetail(
                      formatPercent(sum.savedPercent),
                      context.bytes(sum.originalBytes),
                      context.bytes(sum.compressedBytes),
                    ),
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.photosCompressed(sum.done, sum.total),
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                  if (sum.skipped > 0)
                    Text(
                      l.skippedCount(sum.skipped),
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  if (sum.failed > 0)
                    Text(
                      l.failedCount(sum.failed),
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final r in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ResultTile(result: r, l: l),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.l});

  final CompressionResult result;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = result;
    final canCompare = r.isDone && r.compressedPath != null;

    String subtitle;
    switch (r.status) {
      case ResultStatus.done:
        subtitle =
            '${context.bytes(r.originalBytes)} → ${context.bytes(r.compressedBytes)}';
      case ResultStatus.skippedNotSmaller:
        subtitle = l.notSmaller;
      case ResultStatus.failed:
        subtitle = l.failedItem;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canCompare
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CompareScreen(result: r),
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: r.compressedPath != null
                      ? Image.file(
                          File(r.compressedPath!),
                          fit: BoxFit.cover,
                          cacheWidth: 160,
                        )
                      : ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            r.status == ResultStatus.failed
                                ? Icons.error_outline
                                : Icons.remove_circle_outline,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    if (r.isDone)
                      Text(
                        r.originalDeleted ? l.originalDeleted : l.originalKept,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    if (r.targetReached == false)
                      Text(
                        l.targetNotReached,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.error),
                      ),
                  ],
                ),
              ),
              if (r.isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l.savedPercent(formatPercent(r.savedPercent)),
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
