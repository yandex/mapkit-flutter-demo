import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionsStateUpdatesListenerImpl
    implements OfflineCacheRegionListener {
  final void Function(int) onRegionStateChangedCallback;
  final void Function(int) onRegionProgressCallback;

  RegionsStateUpdatesListenerImpl({
    required this.onRegionStateChangedCallback,
    required this.onRegionProgressCallback,
  });

  @override
  void onRegionStateChanged(int regionId) =>
      onRegionStateChangedCallback(regionId);

  @override
  void onRegionProgress(int regionId) => onRegionProgressCallback(regionId);
}
