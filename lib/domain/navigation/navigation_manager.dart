import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

abstract interface class NavigationManager implements domain.LocationManager {
  Stream<bool> get guidanceActive;
  Stream<bool> get areRoutesBuilt;

  ValueStream<DrivingRoute?> get currentRoute;
  Stream<String> get roadName;
  Stream<String> get roadFlags;

  LocalizedValue? get speedLimit;
  SpeedLimitStatus get speedLimitStatus;
  SpeedLimitsPolicy get speedLimitsPolicy;
  double get speedLimitTolerance;

  void requestRoutes(List<RequestPoint> points);
  void resetRoutes();

  void startGuidance(DrivingRoute route);
  void stopGuidance();

  void resume();
  void suspend();
}

extension IsGuidanceActive on NavigationManager {
  bool get isGuidanceActive => currentRoute.valueOrNull != null;
}
