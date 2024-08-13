import 'package:collection/collection.dart';
import 'package:common/common.dart';
import 'package:map_offline/common/managers/region_list_updates/region_list_updates_manager.dart';
import 'package:map_offline/common/managers/region_state_updates/region_state_updates_manager.dart';
import 'package:map_offline/features/region/state/region_ui_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionManager {
  RegionManager(
    this.offlineCacheManager,
    this.regionListUpdatesManager,
    this.regionStateUpdatesManager,
  );

  final OfflineCacheManager offlineCacheManager;
  final RegionListUpdatesManager regionListUpdatesManager;
  final RegionStateUpdatesManager regionStateUpdatesManager;

  Stream<RegionUiState?> uiState(int regionId) => Rx.combineLatest2(
        _regionStream(regionId),
        regionStateUpdatesManager.regionsStateUpdates,
        (region, _) => region?.let(
          (it) => RegionUiState(
            id: it.id,
            name: it.name,
            country: it.country,
            cities: offlineCacheManager.getCities(it.id),
            center: it.center,
            size: it.size.text,
            downloadProgress: offlineCacheManager.getProgress(region.id),
            parentId: it.parentId,
            state: offlineCacheManager.getState(it.id),
            releaseTime: it.releaseTime.toTimeString(),
            downloadedReleaseTime: offlineCacheManager
                .getDownloadedReleaseTime(it.id)
                ?.toTimeString(),
          ),
        ),
      );

  /// Returns true if offline cache downloading started with success, false
  /// if there may be not enough available disk space on the device.
  bool startDownload(int regionId) {
    if (offlineCacheManager.mayBeOutOfAvailableSpace(regionId)) {
      return false;
    }
    offlineCacheManager.startDownload(regionId);
    return true;
  }

  void stopDownload(int regionId) {
    offlineCacheManager.stopDownload(regionId);
  }

  void pauseDownload(int regionId) {
    offlineCacheManager.pauseDownload(regionId);
  }

  void drop(int regionId) {
    offlineCacheManager.drop(regionId);
  }

  Stream<OfflineCacheRegion?> _regionStream(int regionId) {
    return regionListUpdatesManager.regionsList
        .map((regions) => regions.firstWhereOrNull((it) => it.id == regionId));
  }
}

extension _ToTimeString on DateTime {
  String toTimeString() {
    return "$day.$month.$year";
  }
}
