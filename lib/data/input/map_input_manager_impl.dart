import 'package:navikit_flutter_demo/domain/input/map_input_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class MapInputManagerImpl implements MapInputManager {
  final _longTapActions = PublishSubject<Point>();

  @override
  Stream<Point> get longTapActions => _longTapActions;

  @override
  void onMapLongTap(Map map, Point point) {
    _longTapActions.add(point);
  }

  @override
  void onMapTap(Map map, Point point) {}

  @override
  void dispose() {
    _longTapActions.close();
  }
}
