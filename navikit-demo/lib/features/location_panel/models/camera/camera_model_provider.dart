import 'package:navikit_flutter_demo/domain/camera/camera_manager.dart';
import 'package:navikit_flutter_demo/features/location_panel/models/camera/camera_model.dart';
import 'package:rxdart/rxdart.dart';

final class CameraModelProvider {
  final CameraManager _cameraManager;

  late final model = _cameraManager.cameraPosition
      .map((cameraPosition) => CameraModel(azimuth: cameraPosition.azimuth))
      .share();

  CameraModelProvider(this._cameraManager);
}
