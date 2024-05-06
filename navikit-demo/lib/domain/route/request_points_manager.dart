import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

abstract interface class RequestPointsManager implements DisposableManager {
  Stream<List<RequestPoint>> get requestPoints;

  void setFromPoint(Point point);
  void setToPoint(Point point);
  void setViaPoint(Point point);

  void resetPoints();
}
