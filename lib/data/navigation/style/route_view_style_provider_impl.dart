import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class RouteViewStyleProviderImpl
    implements NavigationRouteViewStyleProvider {
  final NavigationStyleProvider _automotiveNavigationStyleProvider;

  RouteViewStyleProviderImpl(this._automotiveNavigationStyleProvider);

  @override
  void provideJamStyle(
    DrivingFlags flags,
    bool isSelected,
    bool isNightMode,
    NavigationLayerMode layerMode,
    NavigationJamStyle jamStyle,
  ) {
    _automotiveNavigationStyleProvider
        .routeViewStyleProvider()
        .provideJamStyle(flags, isSelected, isNightMode, layerMode, jamStyle);
  }

  @override
  void providePolylineStyle(
    DrivingFlags flags,
    bool isSelected,
    bool isNightMode,
    NavigationLayerMode layerMode,
    PolylineStyle polylineStyle,
  ) {
    _automotiveNavigationStyleProvider
        .routeViewStyleProvider()
        .providePolylineStyle(flags, isSelected, isNightMode, layerMode, polylineStyle);
  }

  @override
  void provideManoeuvreStyle(
    DrivingFlags flags,
    bool isSelected,
    bool isNightMode,
    NavigationLayerMode layerMode,
    ArrowStyle arrowStyle,
  ) {
    _automotiveNavigationStyleProvider
        .routeViewStyleProvider()
        .provideManoeuvreStyle(flags, isSelected, isNightMode, layerMode, arrowStyle);
  }

  @override
  void provideRouteStyle(
    DrivingFlags flags,
    bool isSelected,
    bool isNightMode,
    NavigationLayerMode layerMode,
    NavigationRouteStyle routeStyle,
  ) {
    _automotiveNavigationStyleProvider
        .routeViewStyleProvider()
        .provideRouteStyle(flags, isSelected, isNightMode, layerMode, routeStyle);

    routeStyle.setShowJams(isSelected);

    if (!flags.predicted) {
      routeStyle
        ..setShowRoute(true)
        ..setShowTrafficLights(isSelected)
        ..setShowRoadEvents(isSelected)
        ..setShowBalloons(true)
        ..setShowManoeuvres(isSelected);
    } else {
      routeStyle
        ..setShowRoute(true)
        ..setShowTrafficLights(false)
        ..setShowRoadEvents(true)
        ..setShowBalloons(false)
        ..setShowManoeuvres(false);
    }
  }
}
