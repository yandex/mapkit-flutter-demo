import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/places.dart';
import 'package:yandex_maps_mapkit/search.dart';

extension GeoObjectAirshipTapInfo on GeoObject {
  AirshipTapInfo? get airshipTapInfo {
    return metadataContainer.get(AirshipTapInfo.factory);
  }
}

extension ToponymGeoObjectMetadata on GeoObject {
  SearchToponymObjectMetadata? get toponymMetadata {
    return metadataContainer.get(SearchToponymObjectMetadata.factory);
  }
}

extension PointFromGeometry on GeoObject {
  Point? get pointFromGeometry {
    return geometry
        .map((item) => item.asPoint())
        .whereType<Point>()
        .firstOrNull;
  }
}

extension GeoObjectPoint on GeoObject {
  Point? get point {
    return toponymMetadata?.balloonPoint ?? pointFromGeometry;
  }
}
