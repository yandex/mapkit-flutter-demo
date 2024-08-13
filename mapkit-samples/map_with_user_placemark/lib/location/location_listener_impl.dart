import 'package:yandex_maps_mapkit/mapkit.dart';

final class LocationListenerImpl implements LocationListener {
  final void Function(Location) onLocationUpdate;
  final void Function(LocationStatus) onLocationStatusUpdate;

  const LocationListenerImpl({
    required this.onLocationUpdate,
    required this.onLocationStatusUpdate,
  });

  @override
  void onLocationUpdated(Location location) => onLocationUpdate(location);

  @override
  void onLocationStatusUpdated(LocationStatus status) =>
      onLocationStatusUpdate(status);
}
