import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../l10n/l10n_ext.dart';
import '../models/compression_result.dart';
import '../models/compression_settings.dart';
import '../services/gallery_service.dart';
import '../services/locale_controller.dart';
import '../widgets/empty_state.dart';
import 'picker_screen.dart';
import 'progress_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GalleryService _gallery = GalleryService();
  PermissionState? _permission;
  CompressionSettings _settings = const CompressionSettings();

  Future<void> _start() async {
    final state = await _gallery.requestPermission();
    if (!mounted) return;
    setState(() => _permission = state);
    if (!state.hasAccess) return;

    final picked = await Navigator.of(context).push<PickerOutcome>(
      MaterialPageRoute(
        builder: (_) =>
            PickerScreen(gallery: _gallery, initialSettings: _settings),
      ),
    );
    if (picked == null || !mounted) return;
    _settings = picked.settings;

    final results = await Navigator.of(context).push<List<CompressionResult>>(
      MaterialPageRoute(
        builder: (_) =>
            ProgressScreen(assets: picked.assets, settings: picked.settings),
      ),
    );
    if (results == null || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ResultsScreen(results: results)),
    );
  }

  void _pickLanguage() {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final current = widget.localeController.locale?.languageCode;
        Widget tile(String label, String? code) => ListTile(
          title: Text(label),
          trailing: code == current ? const Icon(Icons.check) : null,
          onTap: () {
            widget.localeController.setLocale(
              code == null ? null : Locale(code),
            );
            Navigator.pop(ctx);
          },
        );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  l.language,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              tile(l.languageSystem, null),
              tile(l.languageEnglish, 'en'),
              tile(l.languageGerman, 'de'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final denied = _permission != null && !_permission!.hasAccess;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: l.language,
            icon: const Icon(Icons.translate),
            onPressed: _pickLanguage,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: denied
            ? EmptyState(
                key: const ValueKey('denied'),
                icon: Icons.lock_outline,
                title: l.permissionTitle,
                body: l.permissionBody,
                actions: [
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l.grantAccess),
                  ),
                  OutlinedButton(
                    onPressed: _gallery.openAppSettings,
                    child: Text(l.openSettings),
                  ),
                ],
              )
            : EmptyState(
                key: const ValueKey('empty'),
                icon: Icons.compress_rounded,
                title: l.emptyTitle,
                body: l.emptyBody,
                actions: [
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(l.pickPhotos),
                  ),
                ],
              ),
      ),
    );
  }
}
