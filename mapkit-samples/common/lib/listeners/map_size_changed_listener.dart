import 'package:yandex_maps_mapkit/mapkit.dart';

final class MapSizeChangedListenerImpl implements MapSizeChangedListener {
  final void Function(MapWindow, int, int) onMapWindowSizeChange;

  const MapSizeChangedListenerImpl({required this.onMapWindowSizeChange});

  @override
  void onMapWindowSizeChanged(
    MapWindow mapWindow,
    int newWidth,
    int newHeight,
  ) {
    onMapWindowSizeChange(mapWindow, newWidth, newHeight);
  }
}
