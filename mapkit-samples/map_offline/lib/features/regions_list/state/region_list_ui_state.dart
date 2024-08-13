import 'package:map_offline/features/regions_list/state/region_list_item.dart';

final class RegionListUiState {
  final String searchQuery;
  final List<RegionListItem> regions;

  const RegionListUiState({
    required this.searchQuery,
    required this.regions,
  });
}
