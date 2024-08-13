import 'package:map_offline/common/managers/listener_manager.dart';
import 'package:map_offline/common/managers/region_state_updates/region_state_updates_listener.dart';
import 'package:map_offline/common/managers/region_state_updates/region_state_updates_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionStateUpdatesManager implements ListenerManager {
  final OfflineCacheManager offlineCacheManager;

  final _regionsStateUpdates = BehaviorSubject<RegionsStateUpdates?>();

  late final _regionStateUpdatesListener = RegionsStateUpdatesListenerImpl(
    onRegionStateChangedCallback: (regionId) {
      _regionsStateUpdates.add(RegionStateChanged(
        regionId: regionId,
        regionState: offlineCacheManager.getState(regionId),
      ));
    },
    onRegionProgressCallback: (regionId) {
      _regionsStateUpdates.add(RegionStateProgressChanged(
        regionId: regionId,
        progress: offlineCacheManager.getProgress(regionId),
      ));
    },
  );

  RegionStateUpdatesManager(this.offlineCacheManager);

  Stream<RegionsStateUpdates?> get regionsStateUpdates => _regionsStateUpdates;

  @override
  void startListening() {
    offlineCacheManager.addRegionListener(_regionStateUpdatesListener);
    _regionsStateUpdates.add(null);
  }

  @override
  void dispose() {
    offlineCacheManager.removeRegionListener(_regionStateUpdatesListener);
    _regionsStateUpdates.close();
  }
}
