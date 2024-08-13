import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/runtime.dart';

final class OfflineCacheErrorListenerImpl
    implements OfflineCacheManagerErrorListener {
  final void Function(Error) onErrorCallback;
  final void Function(Error, int) onRegionErrorCallback;

  const OfflineCacheErrorListenerImpl({
    required this.onErrorCallback,
    required this.onRegionErrorCallback,
  });

  @override
  void onError(Error error) => onErrorCallback(error);

  @override
  void onRegionError(Error error, int regionId) =>
      onRegionErrorCallback(error, regionId);
}
