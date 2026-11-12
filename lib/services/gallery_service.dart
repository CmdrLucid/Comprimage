import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

/// Thin wrapper around photo_manager for permission and listing.
class GalleryService {
  /// Requests (or re-checks) read access to images, including Android 13+
  /// READ_MEDIA_IMAGES / Android 14 partial access.
  Future<PermissionState> requestPermission() {
    return PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: true,
        ),
      ),
    );
  }

  Future<void> openAppSettings() => PhotoManager.openSetting();

  /// Lets the user change the selection on Android 14 / iOS limited access.
  Future<void> manageLimitedAccess() => PhotoManager.presentLimited();

  Future<List<AssetPathEntity>> loadAlbums() {
    return PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        // The default createTimeCond caps results at DateTime.now() at the
        // moment the filter is built. The album keeps that filter, so photos
        // taken afterwards (or with a creation date slightly in the future,
        // e.g. due to camera clock or time zone skew) would never show up.
        createTimeCond: DateTimeCond.def().copyWith(ignore: true),
        // Without ignoreSize, photo_manager adds "width > 0 AND height > 0"
        // to the query. Many camera apps leave these MediaStore columns empty,
        // so their photos would never be listed.
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
  }

  /// Starts listening for gallery changes (new, edited or deleted photos).
  Future<void> watchChanges(void Function() onChange) async {
    _onChange = (_) => onChange();
    PhotoManager.addChangeCallback(_onChange!);
    await PhotoManager.startChangeNotify();
  }

  /// Stops listening for gallery changes.
  Future<void> unwatchChanges() async {
    final cb = _onChange;
    if (cb == null) return;
    _onChange = null;
    PhotoManager.removeChangeCallback(cb);
    await PhotoManager.stopChangeNotify();
  }

  void Function(MethodCall)? _onChange;

  Future<List<AssetEntity>> loadPage(
    AssetPathEntity album,
    int page, {
    int size = 90,
  }) {
    return album.getAssetListPaged(page: page, size: size);
  }
}
