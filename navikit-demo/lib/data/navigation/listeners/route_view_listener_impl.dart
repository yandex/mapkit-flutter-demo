import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class RouteViewListenerImpl implements RouteViewListener {
  final NavigationLayer _navigationLayer;

  const RouteViewListenerImpl(this._navigationLayer);

  @override
  void onRouteViewTap(RouteView routeView) {
    switch (_navigationLayer.routesSource) {
      case RoutesSource.Navigation:
        _navigationLayer.selectRoute(routeView);
      case RoutesSource.Guidance:
        _navigationLayer.navigation.guidance.switchToRoute(routeView.route);
    }
  }

  @override
  void onRouteViewsChanged() {
    if (_navigationLayer.selectedRoute() != null) {
      return;
    }
    _navigationLayer.routes.firstOrNull
        ?.let((it) => _navigationLayer.selectRoute(it));
  }
}
