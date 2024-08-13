import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;

sealed class SearchState {}

final class SearchOff extends SearchState {
  static SearchOff instance = SearchOff._();

  SearchOff._();
}

final class SearchLoading extends SearchState {
  static SearchLoading instance = SearchLoading._();

  SearchLoading._();
}

final class SearchError extends SearchState {
  static SearchError instance = SearchError._();

  SearchError._();
}

final class SearchSuccess extends SearchState {
  final List<SearchResponseItem> items;
  final Map<mapkit.Point, mapkit.GeoObject?> placemarkPointToGeoObject;
  final bool shouldZoomToItems;
  final mapkit.BoundingBox itemsBoundingBox;

  SearchSuccess(
    this.items,
    this.placemarkPointToGeoObject,
    this.shouldZoomToItems,
    this.itemsBoundingBox,
  );
}

final class SearchResponseItem {
  final mapkit.Point point;
  final mapkit.GeoObject? geoObject;

  const SearchResponseItem(this.point, this.geoObject);

  @override
  String toString() {
    return "Point(latitude: ${point.latitude}, longitude: ${point.longitude})";
  }
}
