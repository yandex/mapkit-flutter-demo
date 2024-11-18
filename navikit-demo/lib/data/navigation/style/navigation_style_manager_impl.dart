import 'package:navikit_flutter_demo/data/navigation/style/route_view_style_provider_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/style/user_placemark_style_provider_impl.dart';
import 'package:navikit_flutter_demo/domain/navigation/style/navigation_style_manager.dart';
import 'package:yandex_maps_navikit/automotive_navigation_style_provider.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationStyleManagerImpl implements NavigationStyleManager {
  final NavigationStyleProvider _automotiveNavigationStyleProvider;

  late final NavigationRouteViewStyleProvider _routeViewStyleProvider =
      RouteViewStyleProviderImpl(_automotiveNavigationStyleProvider);

  late final NavigationUserPlacemarkStyleProvider _userPlacemarkStyleProvider =
      UserPlacemarkStyleProviderImpl();

  NavigationStyleManagerImpl(this._automotiveNavigationStyleProvider);

  @override
  NavigationRouteViewStyleProvider routeViewStyleProvider() =>
      _routeViewStyleProvider;

  @override
  NavigationUserPlacemarkStyleProvider userPlacemarkStyleProvider() =>
      _userPlacemarkStyleProvider;

  @override
  NavigationBalloonImageProvider balloonImageProvider() {
    return _automotiveNavigationStyleProvider.balloonImageProvider();
  }

  @override
  NavigationRequestPointStyleProvider requestPointStyleProvider() {
    return _automotiveNavigationStyleProvider.requestPointStyleProvider();
  }

  @override
  NavigationRoutePinsStyleProvider routePinsStyleProvider() {
    return _automotiveNavigationStyleProvider.routePinsStyleProvider();
  }

  @override
  HighlightStyleProvider highlightStyleProvider() {
    return DefaultHighlightStyleProvider();
  }
}
