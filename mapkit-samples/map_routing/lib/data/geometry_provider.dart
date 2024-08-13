import 'package:yandex_maps_mapkit/mapkit.dart';

final class GeometryProvider {
  static const startPosition = CameraPosition(
    Point(latitude: 59.941282, longitude: 30.308046),
    zoom: 13.0,
    azimuth: 0.0,
    tilt: 0.0,
  );

  static const defaultPoints = [
    Point(latitude: 59.954093, longitude: 30.305770),
    Point(latitude: 59.929576, longitude: 30.291737),
  ];
}
