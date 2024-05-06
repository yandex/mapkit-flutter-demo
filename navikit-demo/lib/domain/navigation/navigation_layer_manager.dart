import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/navigation.dart';

abstract interface class NavigationLayerManager implements DisposableManager {
  DrivingRoute? get selectedRoute;

  CameraMode? get cameraMode;
  set cameraMode(CameraMode? value);

  Stream<bool> get isCameraFollowingMode;

  void initIfNeeded();
}
