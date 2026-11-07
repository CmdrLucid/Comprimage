import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/compression_settings.dart';
import '../models/formatting.dart';
import '../models/preset.dart';

/// Shows the per-run settings sheet. Returns the chosen settings or `null`.
Future<CompressionSettings?> showSettingsSheet(
  BuildContext context, {
  required CompressionSettings initial,
  required int count,
}) {
  return showModalBottomSheet<CompressionSettings>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SettingsSheet(initial: initial, count: count),
  );
}

String presetLabel(AppLocalizations l, Preset p) => switch (p) {
  Preset.small => l.presetSmall,
  Preset.medium => l.presetMedium,
  Preset.high => l.presetHigh,
};

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.initial, required this.count});

  final CompressionSettings initial;
  final int count;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late CompressionSettings _s = widget.initial;
  late bool _targetOn = widget.initial.targetBytes != null;
  bool _megabytes = false;
  late final TextEditingController _targetCtrl = TextEditingController(
    text: widget.initial.targetBytes == null
        ? ''
        : (widget.initial.targetBytes! / 1024).round().toString(),
  );

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  void _updateTarget() {
    final bytes = _targetOn
        ? parseTargetBytes(_targetCtrl.text, megabytes: _megabytes)
        : null;
    setState(() => _s = _s.copyWith(targetBytes: () => bytes));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final pad = EdgeInsets.fromLTRB(
      20,
      0,
      20,
      16 + MediaQuery.of(context).viewInsets.bottom,
    );

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsTitle,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          section(
            l.presets,
            Wrap(
              spacing: 8,
              children: [
                for (final p in Preset.values)
                  ChoiceChip(
                    label: Text(presetLabel(l, p)),
                    selected: _s.matchingPreset == p,
                    onSelected: (_) => setState(() => _s = _s.applyPreset(p)),
                  ),
              ],
            ),
          ),
          section(
            l.format,
            SegmentedButton<OutputFormat>(
              segments: [
                for (final f in OutputFormat.values)
                  ButtonSegment(value: f, label: Text(f.label)),
              ],
              selected: {_s.format},
              onSelectionChanged: (v) =>
                  setState(() => _s = _s.copyWith(format: v.first)),
            ),
          ),
          section(
            '${l.quality}: ${_s.quality}',
            Slider(
              value: _s.quality.toDouble(),
              min: kMinQuality.toDouble(),
              max: kMaxQuality.toDouble(),
              divisions: kMaxQuality - kMinQuality,
              label: '${_s.quality}',
              onChanged: (v) =>
                  setState(() => _s = _s.copyWith(quality: v.round())),
            ),
          ),
          section(
            l.maxEdge,
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final e in kMaxEdgeOptions)
                  ChoiceChip(
                    label: Text(e == null ? l.original : l.pixels(e)),
                    selected: _s.maxEdge == e,
                    onSelected: (_) =>
                        setState(() => _s = _s.copyWith(maxEdge: () => e)),
                  ),
              ],
            ),
          ),
          section(
            l.targetSize,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_targetOn ? l.targetValue : l.targetSizeOff),
                  subtitle: Text(l.targetSizeHelp),
                  value: _targetOn,
                  onChanged: (v) {
                    _targetOn = v;
                    _updateTarget();
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: !_targetOn
                      ? const SizedBox(width: double.infinity)
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _targetCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: l.targetValue,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onChanged: (_) => _updateTarget(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                  value: false,
                                  label: Text(l.unitKb),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text(l.unitMb),
                                ),
                              ],
                              selected: {_megabytes},
                              onSelectionChanged: (v) {
                                _megabytes = v.first;
                                _updateTarget();
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.stripMetadata),
            subtitle: Text(l.stripMetadataHelp),
            value: _s.stripMetadata,
            onChanged: (v) =>
                setState(() => _s = _s.copyWith(stripMetadata: v)),
          ),
          const SizedBox(height: 12),
          section(
            l.saveMode,
            RadioGroup<SaveMode>(
              groupValue: _s.saveMode,
              onChanged: (v) => setState(() => _s = _s.copyWith(saveMode: v)),
              child: Column(
                children: [
                  RadioListTile<SaveMode>(
                    contentPadding: EdgeInsets.zero,
                    value: SaveMode.copy,
                    title: Text(l.saveCopy),
                    subtitle: Text(l.saveCopyDesc),
                  ),
                  RadioListTile<SaveMode>(
                    contentPadding: EdgeInsets.zero,
                    value: SaveMode.replace,
                    title: Text(l.saveReplace),
                    subtitle: Text(l.saveReplaceDesc),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              // A switched-on target field without a valid value is ignored.
              onPressed: () => Navigator.pop(context, _s),
              icon: const Icon(Icons.compress),
              label: Text(l.startCompression(widget.count)),
            ),
          ),
        ],
      ),
    );
  }
}
