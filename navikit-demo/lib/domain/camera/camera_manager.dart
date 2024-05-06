import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

abstract interface class CameraManager implements DisposableManager {
  Stream<CameraPosition> get cameraPosition;

  void start();
  void moveCameraToUserLocation();
  void changeZoomByStep(ZoomStep step);
}

enum ZoomStep { plus, minus }
