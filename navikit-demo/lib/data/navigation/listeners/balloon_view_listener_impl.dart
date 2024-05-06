import 'package:yandex_maps_navikit/navigation.dart';

final class BalloonViewListenerImpl implements BalloonViewListener {
  final NavigationLayer _navigationLayer;

  const BalloonViewListenerImpl(this._navigationLayer);

  @override
  void onBalloonViewTap(BalloonView balloonView) {
    final route = balloonView.hostRoute;

    switch (_navigationLayer.routesSource) {
      case RoutesSource.Navigation:
        _navigationLayer.selectRoute(_navigationLayer.getView(route));

      case RoutesSource.Guidance:
        if (balloonView.balloon.asAlternativeBalloon() != null) {
          _navigationLayer.navigation.guidance.switchToRoute(route);
        }
    }
  }

  @override
  void onBalloonVisibilityChanged(BalloonView balloon) {}

  @override
  void onBalloonViewsChanged(RouteView route) {}

  @override
  void onBalloonContentChanged(BalloonView balloon) {}
}
