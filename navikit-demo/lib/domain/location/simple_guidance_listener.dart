import 'package:yandex_maps_navikit/navigation.dart';

abstract class SimpleGuidanceListener implements GuidanceListener {
  @override
  void onAlternativesChanged() {}

  @override
  void onCurrentRouteChanged(RouteChangeReason reason) {}

  @override
  void onFastestAlternativeChanged() {}

  @override
  void onLocationChanged() {}

  @override
  void onReturnedToRoute() {}

  @override
  void onRoadNameChanged() {}

  @override
  void onRouteFinished() {}

  @override
  void onRouteLost() {}

  @override
  void onSpeedLimitStatusUpdated() {}

  @override
  void onSpeedLimitUpdated() {}

  @override
  void onStandingStatusChanged() {}

  @override
  void onWayPointReached() {}
}
