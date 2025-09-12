import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:navikit_flutter_demo/domain/location/simple_guidance_listener.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationGuidanceListener extends SimpleGuidanceListener {
  final StreamController<Location?> _locationController;
  final Guidance _guidance;
  final VoidCallback _onRouteFinished;
  final void Function(String) _onRoadNameChanged;
  final void Function(DrivingRoute?) _onCurrentRouteChanged;

  var _lastLocationTime = 0;
  static const _locationUpdateTimeout = Duration(seconds: 1);

  NavigationGuidanceListener(
    this._locationController,
    this._guidance, {
    required VoidCallback onRouteFinished,
    required void Function(String) onRoadNameChanged,
    required void Function(DrivingRoute?) onCurrentRouteChanged,
  })  : _onRouteFinished = onRouteFinished,
        _onRoadNameChanged = onRoadNameChanged,
        _onCurrentRouteChanged = onCurrentRouteChanged;

  @override
  void onLocationChanged() {
    final timePassed =
        DateTime.now().millisecondsSinceEpoch - _lastLocationTime;

    if (Duration(milliseconds: timePassed) >= _locationUpdateTimeout) {
      _lastLocationTime = DateTime.now().millisecondsSinceEpoch;
      _locationController.add(_guidance.location);
    }
  }

  @override
  void onRouteFinished() => _onRouteFinished();

  @override
  void onRoadNameChanged() => _onRoadNameChanged(_guidance.roadName ?? "");

  @override
  void onCurrentRouteChanged(RouteChangeReason reason) =>
      _onCurrentRouteChanged(_guidance.currentRoute);
}
