import 'package:collection/collection.dart';
import 'package:common/common.dart';
import 'package:map_offline/common/managers/region_list_updates/region_list_updates_manager.dart';
import 'package:map_offline/common/managers/region_state_updates/region_state_updates_manager.dart';
import 'package:map_offline/features/regions_list/state/region_list_item.dart';
import 'package:map_offline/features/regions_list/state/region_list_ui_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionListManager {
  RegionListManager(
    this.offlineCacheManager,
    this.regionListUpdatesManager,
    this.regionStateUpdatesManager,
  );

  final OfflineCacheManager offlineCacheManager;
  final RegionListUpdatesManager regionListUpdatesManager;
  final RegionStateUpdatesManager regionStateUpdatesManager;

  final _searchQuery = BehaviorSubject<String>()..add("");

  late final uiState = Rx.combineLatest3(
    regionListUpdatesManager.regionsList,
    regionStateUpdatesManager.regionsStateUpdates,
    _searchQuery,
    (regions, _, query) {
      final (completed, available) = regions
          .where((it) => it.name.toLowerCase().contains(query.toLowerCase()))
          .partition((region) =>
              offlineCacheManager.getState(region.id).isCompleted());

      final regionsList = <RegionListItem>[];

      if (completed.isNotEmpty) {
        regionsList.add(SectionItem(title: "Downloaded"));
        regionsList.addAll(completed.process((offlineCacheManager.getCities)));
      }
      if (available.isNotEmpty) {
        regionsList.add(SectionItem(title: "Available"));
        regionsList.addAll(available.process((offlineCacheManager.getCities)));
      }
      return RegionListUiState(searchQuery: query, regions: regionsList);
    },
  ).publishValue();

  void searchRegions(String newQuery) => _searchQuery.add(newQuery);
}

extension _ProcessRegions on List<OfflineCacheRegion> {
  List<RegionItem> process(List<String> Function(int id) getCities) {
    return map(
      (item) => RegionItem(
        id: item.id,
        name: item.name,
        cities: getCities(item.id),
      ),
    ).sortedBy((it) => it.name);
  }
}

extension _IsRegionStateCompleted on OfflineCacheRegionState {
  bool isCompleted() => switch (this) {
        OfflineCacheRegionState.Completed => true,
        _ => false,
      };
}
