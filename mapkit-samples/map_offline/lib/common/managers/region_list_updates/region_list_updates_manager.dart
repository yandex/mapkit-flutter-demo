import 'package:map_offline/common/managers/listener_manager.dart';
import 'package:map_offline/common/managers/region_list_updates/region_list_updates_listener.dart';
import 'package:rxdart/subjects.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionListUpdatesManager implements ListenerManager {
  final OfflineCacheManager offlineCacheManager;

  final _regionsList = BehaviorSubject<List<OfflineCacheRegion>>();

  late final _regionsListUpdatesListener = RegionListUpdatesListenerImpl(
    onListUpdatedCallback: () {
      _regionsList.add(offlineCacheManager.regions());
    },
  );

  RegionListUpdatesManager(this.offlineCacheManager);

  Stream<List<OfflineCacheRegion>> get regionsList => _regionsList;

  @override
  void startListening() {
    offlineCacheManager
        .addRegionListUpdatesListener(_regionsListUpdatesListener);
    _regionsList.add(offlineCacheManager.regions());
  }

  @override
  void dispose() {
    offlineCacheManager
        .removeRegionListUpdatesListener(_regionsListUpdatesListener);
    _regionsList.close();
  }
}
