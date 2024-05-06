import 'package:yandex_maps_navikit/mapkit.dart';

final class CameraPositionListenerImpl implements MapCameraListener {
  final void Function(CameraPosition) _onCameraPositionChanged;

  const CameraPositionListenerImpl(this._onCameraPositionChanged);

  @override
  void onCameraPositionChanged(Map map, CameraPosition cameraPosition,
      CameraUpdateReason cameraUpdateReason, bool finished) {
    _onCameraPositionChanged(cameraPosition);
  }
}
