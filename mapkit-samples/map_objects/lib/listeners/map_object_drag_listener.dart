import 'package:yandex_maps_mapkit/mapkit.dart';

final class MapObjectDragListenerImpl implements MapObjectDragListener {
  final void Function(MapObject) onMapObjectDragStartCallback;
  final void Function(MapObject, Point) onMapObjectDragCallback;
  final void Function(MapObject) onMapObjectDragEndCallback;

  const MapObjectDragListenerImpl({
    required this.onMapObjectDragStartCallback,
    required this.onMapObjectDragCallback,
    required this.onMapObjectDragEndCallback,
  });

  @override
  void onMapObjectDragStart(MapObject mapObject) =>
      onMapObjectDragStartCallback(mapObject);

  @override
  void onMapObjectDrag(MapObject mapObject, Point point) =>
      onMapObjectDragCallback(mapObject, point);

  @override
  void onMapObjectDragEnd(MapObject mapObject) =>
      onMapObjectDragEndCallback(mapObject);
}
