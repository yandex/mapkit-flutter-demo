import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

abstract interface class MapInputManager extends MapInputListener
    implements DisposableManager {
  Stream<Point> get longTapActions;
}
