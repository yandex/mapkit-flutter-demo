import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationLayerListenerImpl implements NavigationLayerListener {
  final NavigationLayer _navigationLayer;
  final void Function(DrivingRoute?) _onSelectedRouteChanged;

  const NavigationLayerListenerImpl(
    this._navigationLayer, {
    required void Function(DrivingRoute?) onSelectedRouteChanged,
  }) : _onSelectedRouteChanged = onSelectedRouteChanged;

  @override
  void onSelectedRouteChanged() {
    _onSelectedRouteChanged(_navigationLayer.selectedRoute()?.route);
  }

  @override
  void onRoutesSourceChanged() {}
}
