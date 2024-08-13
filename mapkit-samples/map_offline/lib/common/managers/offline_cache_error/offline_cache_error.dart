import 'package:yandex_maps_mapkit/runtime.dart';

sealed class OfflineCacheError {
  final Error error;

  const OfflineCacheError(this.error);
}

final class OfflineCacheManagerError extends OfflineCacheError {
  const OfflineCacheManagerError(Error error) : super(error);
}

final class OfflineCacheRegionError extends OfflineCacheError {
  final int regionId;

  const OfflineCacheRegionError(Error error, this.regionId) : super(error);
}
