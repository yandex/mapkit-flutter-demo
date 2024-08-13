import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionUiState {
  final int id;
  final String name;
  final String country;
  final List<String> cities;
  final Point center;
  final String size;
  final double downloadProgress;
  final int? parentId;
  final OfflineCacheRegionState state;
  final String releaseTime;
  final String? downloadedReleaseTime;

  const RegionUiState({
    required this.id,
    required this.name,
    required this.country,
    required this.cities,
    required this.center,
    required this.size,
    required this.downloadProgress,
    required this.parentId,
    required this.state,
    required this.releaseTime,
    required this.downloadedReleaseTime,
  });
}
