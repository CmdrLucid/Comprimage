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
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
  }

  Future<List<AssetEntity>> loadPage(
    AssetPathEntity album,
    int page, {
    int size = 90,
  }) {
    return album.getAssetListPaged(page: page, size: size);
  }
}
