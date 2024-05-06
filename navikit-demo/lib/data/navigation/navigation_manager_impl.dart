import 'dart:async';

import 'package:navikit_flutter_demo/core/resources/strings/route_strings.dart';
import 'package:navikit_flutter_demo/data/navigation/listeners/navigation_guidance_listener.dart';
import 'package:navikit_flutter_demo/data/navigation/listeners/navigation_listener_impl.dart';
import 'package:navikit_flutter_demo/domain/alerts/snackbars/snackbar_factory.dart';
import 'package:navikit_flutter_demo/domain/location/simple_guidance_listener.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/route/request_points_manager.dart';
import 'package:navikit_flutter_demo/domain/simulation/simulation_manager.dart';
import 'package:navikit_flutter_demo/domain/utils/route_utils.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationManagerImpl implements NavigationManager {
  final RequestPointsManager _requestPointsManager;
  final SimulationManager _simulationManager;
  final Navigation _navigation;
  final SnackBarFactory _snackBarFactory;

  final _location = BehaviorSubject<Location?>();
  final _currentRoute = BehaviorSubject<DrivingRoute?>();
  final _areRoutesBuilt = BehaviorSubject<bool>();
  final _roadName = BehaviorSubject<String>()..add("");

  late final _roadFlags =
      _currentRoute.map((it) => it?.buildFlagsString() ?? "");

  late final NavigationListener _navigationListener = NavigationListenerImpl(
    onRoutesBuiltCallback: () {
      if (_navigation.routes.isNotEmpty) {
        _areRoutesBuilt.add(true);
      } else {
        _areRoutesBuilt.add(false);
        _requestPointsManager.resetPoints();
        _snackBarFactory.showSnackBar(RouteStrings.cantBuildRouteText);
      }
    },
  );

  late final SimpleGuidanceListener _guidanceListener =
      NavigationGuidanceListener(_location, _navigation.guidance,
          onRouteFinished: stopGuidance,
          onRoadNameChanged: _roadName.add,
          onCurrentRouteChanged: _currentRoute.add);

  NavigationManagerImpl(
    this._requestPointsManager,
    this._simulationManager,
    this._navigation,
    this._snackBarFactory,
  );

  @override
  ValueStream<Location?> get location => _location;

  @override
  Stream<bool> get guidanceActive => currentRoute.map((it) => it != null);

  @override
  Stream<bool> get areRoutesBuilt => _areRoutesBuilt;

  @override
  ValueStream<DrivingRoute?> get currentRoute => _currentRoute;

  @override
  Stream<String> get roadName => _roadName;

  @override
  Stream<String> get roadFlags => _roadFlags;

  @override
  LocalizedValue? get speedLimit => _navigation.guidance.speedLimit;

  @override
  SpeedLimitStatus get speedLimitStatus =>
      _navigation.guidance.speedLimitStatus;

  @override
  SpeedLimitsPolicy get speedLimitsPolicy =>
      _navigation.guidance.speedLimitsPolicy;

  @override
  double get speedLimitTolerance => _navigation.guidance.speedLimitTolerance;

  @override
  void startListening() {
    _listenForNavigation();
  }

  @override
  void requestRoutes(List<RequestPoint> points) {
    _navigation.vehicleOptions = _defaultVehicleOptions();
    _navigation.requestRoutes(
        points: points, initialAzimuth: _navigation.guidance.location?.heading);
  }

  @override
  void resetRoutes() {
    _navigation.resetRoutes();
  }

  @override
  void startGuidance(DrivingRoute route) {
    final routeIds = _navigation.routes.map((it) => it.routeId);
    if (routeIds.contains(route.routeId) ||
        _navigation.guidance.currentRoute == null) {
      _navigation.startGuidance(route);
    }

    _navigation.guidance.currentRoute?.let((it) {
      _simulationManager.startSimulation(it);
    });
  }

  @override
  void stopGuidance() {
    _requestPointsManager.resetPoints();
    _navigation.stopGuidance();
    _navigation.resetRoutes();
    _simulationManager.stopSimulation();
  }

  @override
  void resume() {
    _navigation.resume();
    _simulationManager.resume();
  }

  @override
  void suspend() {
    _navigation.suspend();
    _simulationManager.suspend();
  }

  @override
  void dispose() {
    _navigation.removeListener(_navigationListener);
    _navigation.guidance.removeListener(_guidanceListener);
    _location.close();
    _currentRoute.close();
    _roadName.close();
    _areRoutesBuilt.close();
  }

  DrivingVehicleOptions _defaultVehicleOptions() {
    return const DrivingVehicleOptions(vehicleType: DrivingVehicleType.Default);
  }

  void _listenForNavigation() {
    _navigation.addListener(_navigationListener);
    _navigation.guidance.let((it) {
      _currentRoute.add(it.currentRoute);
      _roadName.add(it.roadName ?? "");

      it.addListener(_guidanceListener);
    });
  }
}
