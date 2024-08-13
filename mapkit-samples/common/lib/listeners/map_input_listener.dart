import 'package:yandex_maps_mapkit/mapkit.dart';

final class MapInputListenerImpl implements MapInputListener {
  final void Function(Map, Point) onMapTapCallback;
  final void Function(Map, Point) onMapLongTapCallback;

  const MapInputListenerImpl({
    required this.onMapTapCallback,
    required this.onMapLongTapCallback,
  });

  @override
  void onMapTap(Map map, Point point) => onMapTapCallback(map, point);

  @override
  void onMapLongTap(Map map, Point point) => onMapLongTapCallback(map, point);
}
