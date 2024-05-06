import 'package:yandex_maps_navikit/navigation.dart';

final class CameraListenerImpl implements CameraListener {
  final void Function() _onCameraModeChanged;

  const CameraListenerImpl(this._onCameraModeChanged);

  @override
  void onCameraModeChanged() => _onCameraModeChanged();
}
