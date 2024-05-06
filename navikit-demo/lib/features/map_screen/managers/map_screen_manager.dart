import 'dart:async';

import 'package:navikit_flutter_demo/domain/input/map_input_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/features/disposable_screen_manager.dart';
import 'package:navikit_flutter_demo/features/route_variants_panel/managers/route_variants_screen_manager.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class MapTapScreenManager implements DisposableScreenManager {
  final NavigationManager _navigationManager;
  final MapInputManager _mapInputManager;
  final RouteVariantsScreenManager _routeVariantsScreenManager;

  StreamSubscription<Point>? _mapInputSubscription;

  MapTapScreenManager(
    this._navigationManager,
    this._mapInputManager,
    this._routeVariantsScreenManager,
  );

  void startListeningForTaps() {
    _mapInputSubscription?.cancel();
    _mapInputSubscription = _mapInputManager.longTapActions.listen((point) {
      if (!_navigationManager.isGuidanceActive) {
        if (_routeVariantsScreenManager.isRouteVariantsVisible.valueOrNull !=
            true) {
          _routeVariantsScreenManager.showRequestToPointDialog(point);
        } else {
          _routeVariantsScreenManager.showRequestPointDialog(point);
        }
      }
    });
  }

  @override
  void dispose() {
    _mapInputSubscription?.cancel();
  }
}
