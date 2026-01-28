import 'dart:async';

import 'package:navikit_flutter_demo/data/camera/listeners/camera_position_listener_impl.dart';
import 'package:navikit_flutter_demo/domain/camera/camera_manager.dart';
import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/utils/camera_utils.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class CameraManagerImpl implements CameraManager {
  final MapWindow _mapWindow;
  final domain.LocationManager _locationManager;

  final _cameraPosition = BehaviorSubject<CameraPosition>();
  late final _cameraPositionListener = CameraPositionListenerImpl(
    (cameraPosition) => _cameraPosition.add(cameraPosition),
  );

  StreamSubscription<Location?>? _locationSubscription;
  Location? _location;
  var _isLocationUnknown = true;

  static const _mapDefaultZoom = 15.0;
  static const _mapZoomStep = 1.0;

  CameraManagerImpl(
    this._mapWindow,
    this._locationManager,
  );

  @override
  Stream<CameraPosition> get cameraPosition => _cameraPosition;

  @override
  void moveCameraToUserLocation() {
    _location?.let((location) {
      final map = _mapWindow.map;

      final cameraPosition = map.cameraPosition;
      final newZoom = cameraPosition.zoom < _mapDefaultZoom
          ? _mapDefaultZoom
          : cameraPosition.zoom;

      final newCameraPosition = CameraPosition(
        location.position,
        zoom: newZoom,
        azimuth: cameraPosition.azimuth,
        tilt: 0.0,
      );

      map.move(
        newCameraPosition,
        animation: CameraAnimations.defaultAnimation,
        cameraCallback: MapCameraCallback(onMoveFinished: (_) {}),
      );
    });
  }

  @override
  void start() {
    _stop();
    _mapWindow.map.addCameraListener(_cameraPositionListener);

    _locationSubscription = _locationManager.location
        .where((location) => location != null)
        .listen((location) {
      _location = location;

      if (location != null && _isLocationUnknown) {
        _isLocationUnknown = false;
        moveCameraToUserLocation();
      }
    });
  }

  @override
  void changeZoomByStep(ZoomStep step) {
    final stepValue = (step == ZoomStep.plus) ? _mapZoomStep : -_mapZoomStep;

    final newCameraPosition = _mapWindow.map.cameraPosition.let(
      (it) => CameraPosition(
        it.target,
        zoom: it.zoom + stepValue,
        azimuth: it.azimuth,
        tilt: it.tilt,
      ),
    );

    _mapWindow.map.move(
      newCameraPosition,
      animation: CameraAnimations.defaultAnimation,
      cameraCallback: MapCameraCallback(onMoveFinished: (_) {}),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapWindow.map.removeCameraListener(_cameraPositionListener);
    _cameraPosition.close();
  }

  void _stop() {
    _locationSubscription?.cancel();
    _mapWindow.map.removeCameraListener(_cameraPositionListener);
  }
}
