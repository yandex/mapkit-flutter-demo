import 'package:yandex_maps_mapkit/mapkit.dart';

final class MapObjectVisitorImpl implements MapObjectVisitor {
  final void Function(PlacemarkMapObject) onPlacemarkVisitedCallback;
  final void Function(PolylineMapObject) onPolylineVisitedCallback;
  final void Function(PolygonMapObject) onPolygonVisitedCallback;
  final void Function(CircleMapObject) onCircleVisitedCallback;
  final bool Function(MapObjectCollection) onCollectionVisitStartCallback;
  final void Function(MapObjectCollection) onCollectionVisitEndCallback;
  final bool Function(ClusterizedPlacemarkCollection)
      onClusterizedCollectionVisitStartCallback;
  final void Function(ClusterizedPlacemarkCollection)
      onClusterizedCollectionVisitEndCallback;

  const MapObjectVisitorImpl({
    required this.onPlacemarkVisitedCallback,
    required this.onPolylineVisitedCallback,
    required this.onPolygonVisitedCallback,
    required this.onCircleVisitedCallback,
    required this.onCollectionVisitStartCallback,
    required this.onCollectionVisitEndCallback,
    required this.onClusterizedCollectionVisitStartCallback,
    required this.onClusterizedCollectionVisitEndCallback,
  });

  @override
  void onPlacemarkVisited(PlacemarkMapObject placemark) =>
      onPlacemarkVisitedCallback(placemark);

  @override
  void onPolylineVisited(PolylineMapObject polyline) =>
      onPolylineVisitedCallback(polyline);

  @override
  void onPolygonVisited(PolygonMapObject polygon) =>
      onPolygonVisitedCallback(polygon);

  @override
  void onCircleVisited(CircleMapObject circle) =>
      onCircleVisitedCallback(circle);

  @override
  bool onCollectionVisitStart(MapObjectCollection collection) =>
      onCollectionVisitStartCallback(collection);

  @override
  void onCollectionVisitEnd(MapObjectCollection collection) =>
      onCollectionVisitEndCallback(collection);

  @override
  bool onClusterizedCollectionVisitStart(
    ClusterizedPlacemarkCollection collection,
  ) {
    return onClusterizedCollectionVisitStartCallback(collection);
  }

  @override
  void onClusterizedCollectionVisitEnd(
    ClusterizedPlacemarkCollection collection,
  ) {
    return onClusterizedCollectionVisitEndCallback(collection);
  }
}
