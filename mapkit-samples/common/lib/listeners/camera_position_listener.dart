import 'package:yandex_maps_mapkit/mapkit.dart';

final class CameraPositionListenerImpl implements MapCameraListener {
  final void Function(
    Map map,
    CameraPosition cameraPosition,
    CameraUpdateReason cameraUpdateReason,
    bool isFinished,
  ) _onCameraPositionChanged;

  const CameraPositionListenerImpl(this._onCameraPositionChanged);

  @override
  void onCameraPositionChanged(
    Map map,
    CameraPosition cameraPosition,
    CameraUpdateReason cameraUpdateReason,
    bool finished,
  ) {
    _onCameraPositionChanged(map, cameraPosition, cameraUpdateReason, finished);
  }
}
