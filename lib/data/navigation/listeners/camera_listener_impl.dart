import 'package:flutter/foundation.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class CameraListenerImpl implements CameraListener {
  final VoidCallback _onCameraModeChanged;

  const CameraListenerImpl(this._onCameraModeChanged);

  @override
  void onCameraModeChanged() => _onCameraModeChanged();
}
