import 'package:yandex_maps_mapkit/mapkit.dart';

sealed class RegionsStateUpdates {
  final int regionId;

  const RegionsStateUpdates(this.regionId);
}

final class RegionStateProgressChanged extends RegionsStateUpdates {
  final double progress;

  const RegionStateProgressChanged({
    required int regionId,
    required this.progress,
  }) : super(regionId);
}

final class RegionStateChanged extends RegionsStateUpdates {
  final OfflineCacheRegionState regionState;

  const RegionStateChanged({
    required int regionId,
    required this.regionState,
  }) : super(regionId);
}
