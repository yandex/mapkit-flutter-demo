import 'package:yandex_maps_mapkit/mapkit.dart';

final class LayersGeoObjectTapListenerImpl
    implements LayersGeoObjectTapListener {
  final bool Function(GeoObjectTapEvent) onObjectTapped;

  const LayersGeoObjectTapListenerImpl({
    required this.onObjectTapped,
  });

  @override
  bool onObjectTap(GeoObjectTapEvent event) => onObjectTapped(event);
}
