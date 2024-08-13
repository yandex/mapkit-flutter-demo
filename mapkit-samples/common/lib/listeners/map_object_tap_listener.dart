import 'package:yandex_maps_mapkit/mapkit.dart';

final class MapObjectTapListenerImpl implements MapObjectTapListener {
  final bool Function(MapObject, Point) onMapObjectTapped;

  const MapObjectTapListenerImpl({required this.onMapObjectTapped});

  @override
  bool onMapObjectTap(MapObject mapObject, Point point) {
    return onMapObjectTapped(mapObject, point);
  }
}
