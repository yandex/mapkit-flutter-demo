import 'dart:async';

import 'package:navikit_flutter_demo/data/navigation/listeners/balloon_view_listener_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/listeners/camera_listener_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/listeners/navigation_layer_listener_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/listeners/route_view_listener_impl.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_layer_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/style/navigation_style_manager.dart';
import 'package:navikit_flutter_demo/domain/utils/camera_utils.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationLayerManagerImpl implements NavigationLayerManager {
  final MapWindow _mapWindow;
  final RoadEventsLayer _roadEventsLayer;
  final NavigationStyleManager _navigationStyleManager;
  final Navigation _navigation;

  final _isCameraFollowingMode = BehaviorSubject<bool>()..add(false);

  late final NavigationLayer _navigationLayer;

  var _isInitialized = false;

  late var _currentDrivingRoute = _navigationLayer.selectedRoute()?.route;

  RouteViewListener? _routeViewListener;
  BalloonViewListenerImpl? _balloonViewListener;
  NavigationLayerListener? _navigationLayerListener;
  CameraListener? _cameraListener;

  NavigationLayerManagerImpl(
    this._mapWindow,
    this._roadEventsLayer,
    this._navigationStyleManager,
    this._navigation,
  );

  @override
  DrivingRoute? get selectedRoute => _currentDrivingRoute;

  @override
  CameraMode? get cameraMode => _navigationLayer.camera.cameraMode();

  @override
  set cameraMode(CameraMode? value) {
    value?.let((it) => _navigationLayer.camera
        .setCameraMode(it, animation: CameraAnimations.defaultAnimation));
  }

  @override
  Stream<bool> get isCameraFollowingMode => _isCameraFollowingMode;

  @override
  void initIfNeeded() {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    _createLayer();
  }

  @override
  void dispose() {
    _removeAllListeners();
    _isCameraFollowingMode.close();
    _isInitialized = false;
  }

  Future<void> _createLayer() async {
    for (final tag in RoadEventsEventTag.values) {
      _roadEventsLayer.setRoadEventVisibleOnRoute(tag, on: true);
    }
    _navigationLayer = NavigationLayerFactory.createNavigationLayer(
        _mapWindow, _roadEventsLayer, _navigationStyleManager, _navigation);
    _addAllListeners();
  }

  void _addAllListeners() {
    final routeViewListener = RouteViewListenerImpl(_navigationLayer)
        .also((it) => _routeViewListener = it);

    final balloonViewListener = BalloonViewListenerImpl(_navigationLayer)
        .also((it) => _balloonViewListener = it);

    final navigationLayerListener = NavigationLayerListenerImpl(
            _navigationLayer,
            onSelectedRouteChanged: (route) => _currentDrivingRoute = route)
        .also((it) => _navigationLayerListener = it);

    final cameraListener = CameraListenerImpl(() {
      _isCameraFollowingMode
          .add(_navigationLayer.camera.cameraMode() == CameraMode.Following);
    }).also((it) => _cameraListener = it);

    _navigationLayer.addRouteViewListener(routeViewListener);
    _navigationLayer.addBalloonViewListener(balloonViewListener);
    _navigationLayer.addListener(navigationLayerListener);
    _navigationLayer.camera.addListener(cameraListener);
  }

  void _removeAllListeners() {
    _routeViewListener
        ?.let((it) => _navigationLayer.removeRouteViewListener(it));
    _balloonViewListener
        ?.let((it) => _navigationLayer.removeBalloonViewListener(it));
    _navigationLayerListener?.let((it) => _navigationLayer.removeListener(it));
    _cameraListener?.let((it) => _navigationLayer.camera.removeListener(it));
  }
}
