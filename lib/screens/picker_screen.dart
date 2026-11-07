import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_ext.dart';
import '../models/compression_settings.dart';
import '../services/gallery_service.dart';
import '../widgets/asset_thumb.dart';
import '../widgets/empty_state.dart';
import 'settings_sheet.dart';

/// Selected assets plus the settings chosen for the run.
class PickerOutcome {
  const PickerOutcome(this.assets, this.settings);
  final List<AssetEntity> assets;
  final CompressionSettings settings;
}

class PickerScreen extends StatefulWidget {
  const PickerScreen({
    super.key,
    required this.gallery,
    required this.initialSettings,
  });

  final GalleryService gallery;
  final CompressionSettings initialSettings;

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  static const int _pageSize = 90;

  final ScrollController _scroll = ScrollController();
  final Map<String, AssetEntity> _selected = {}; // insertion ordered
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _album;
  final List<AssetEntity> _assets = [];
  int _page = 0;
  bool _loading = true;
  bool _hasMore = true;
  bool _error = false;
  bool _limited = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final state = await widget.gallery.requestPermission();
      _limited = state.isLimited;
      _albums = await widget.gallery.loadAlbums();
      _album = _albums.isEmpty ? null : _albums.first;
      await _loadMore(reset: true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) _loadMore();
  }

  Future<void> _loadMore({bool reset = false}) async {
    final album = _album;
    if (album == null) return;
    if (reset) {
      _page = 0;
      _hasMore = true;
      _assets.clear();
    }
    if (!_hasMore) return;
    final page = _page;
    _page++; // guard against parallel loads
    final items = await widget.gallery.loadPage(album, page, size: _pageSize);
    if (!mounted || album != _album) return;
    setState(() {
      _assets.addAll(items);
      if (items.length < _pageSize) _hasMore = false;
    });
  }

  Future<void> _switchAlbum(AssetPathEntity album) async {
    setState(() {
      _album = album;
      _loading = true;
    });
    await _loadMore(reset: true);
    if (mounted) setState(() => _loading = false);
  }

  void _toggle(AssetEntity a) {
    setState(() {
      if (_selected.remove(a.id) == null) _selected[a.id] = a;
    });
  }

  Future<void> _next() async {
    final settings = await showSettingsSheet(
      context,
      initial: widget.initialSettings,
      count: _selected.length,
    );
    if (settings == null || !mounted) return;
    Navigator.of(context)
        .pop(PickerOutcome(_selected.values.toList(), settings));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: _albums.isEmpty
            ? Text(l.pickPhotos)
            : DropdownButtonHideUnderline(
                child: DropdownButton<AssetPathEntity>(
                  value: _album,
                  borderRadius: BorderRadius.circular(16),
                  style: Theme.of(context).textTheme.titleLarge,
                  items: [
                    for (final a in _albums)
                      DropdownMenuItem(
                        value: a,
                        child: Text(a.isAll ? l.allPhotos : a.name),
                      ),
                  ],
                  onChanged: (a) => a == null ? null : _switchAlbum(a),
                ),
              ),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              tooltip: l.clearSelection,
              icon: const Icon(Icons.deselect),
              onPressed: () => setState(_selected.clear),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_limited)
            MaterialBanner(
              content: Text(l.limitedBanner),
              leading: const Icon(Icons.info_outline),
              actions: [
                TextButton(
                  onPressed: () async {
                    await widget.gallery.manageLimitedAccess();
                    if (mounted) _init();
                  },
                  child: Text(l.manageSelection),
                ),
              ],
            ),
          Expanded(child: _buildBody(l, scheme)),
        ],
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _selected.isEmpty
            ? const SizedBox(width: double.infinity)
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.selectedCount(_selected.length),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l.continueLabel),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l, ColorScheme scheme) {
    if (_loading && _assets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return EmptyState(
        icon: Icons.error_outline,
        title: l.errorLoading,
        body: '',
        actions: [
          OutlinedButton(
            onPressed: widget.gallery.openAppSettings,
            child: Text(l.openSettings),
          ),
        ],
      );
    }
    if (_assets.isEmpty) {
      return EmptyState(
        icon: Icons.photo_outlined,
        title: l.noPhotos,
        body: '',
      );
    }
    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: _assets.length,
      itemBuilder: (context, i) {
        final a = _assets[i];
        final sel = _selected.containsKey(a.id);
        return GestureDetector(
          onTap: () => _toggle(a),
          child: AnimatedScale(
            scale: sel ? 0.9 : 1,
            duration: const Duration(milliseconds: 150),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(sel ? 14 : 4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AssetThumb(asset: a),
                  if (sel)
                    ColoredBox(color: scheme.primary.withValues(alpha: 0.28)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? scheme.primary : Colors.black26,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: sel
                          ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
