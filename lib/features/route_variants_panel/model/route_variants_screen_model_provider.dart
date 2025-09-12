import 'package:navikit_flutter_demo/features/route_variants_panel/model/route_variants_screen_model.dart';
import 'package:rxdart/rxdart.dart';

final class RouteVariantsScreenModelProvider {
  final Stream<bool> _routeVariantsVisibility;

  late final model = _routeVariantsVisibility.map((isVisible) {
    return RouteVariantsScreenModel(isRouteVariantsVisible: isVisible);
  }).share();

  RouteVariantsScreenModelProvider(this._routeVariantsVisibility);
}
