import 'package:map_search/features/details/state/geo_object_type.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class DetailsBottomSheetUiState {
  final String title;
  final String description;
  final Point? location;
  final String? uri;
  final GeoObjectType geoObjectType;

  const DetailsBottomSheetUiState({
    required this.title,
    required this.description,
    required this.location,
    required this.uri,
    required this.geoObjectType,
  });
}
