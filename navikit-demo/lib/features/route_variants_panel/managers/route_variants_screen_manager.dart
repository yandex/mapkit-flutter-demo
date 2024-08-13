import 'dart:async';

import 'package:navikit_flutter_demo/dependencies/application_deps/application_deps_provider.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialogs_factory.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/route/request_points_manager.dart';
import 'package:navikit_flutter_demo/features/disposable_screen_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class RouteVariantsScreenManager implements DisposableScreenManager {
  final NavigationManager _navigationManager;
  final RequestPointsManager _requestPointsManager;
  final DialogsFactory _dialogsFactory;

  late final isRouteVariantsVisible = Rx.combineLatest3(
    _requestPointsManager.requestPoints,
    navigationManager.areRoutesBuilt,
    navigationManager.guidanceActive,
    (points, areRoutesBuilt, isGuidanceActive) {
      return points.isNotEmpty && areRoutesBuilt && !isGuidanceActive;
    },
  ).shareValue();

  StreamSubscription<List<RequestPoint>>? _requestPointsSubscription;

  RouteVariantsScreenManager(
    this._navigationManager,
    this._requestPointsManager,
    this._dialogsFactory,
  );

  void showRequestToPointDialog(Point point) {
    _dialogsFactory.showRequestToPointDialog(primaryAction: () {
      _requestPointsManager.setToPoint(point);
      _listenForRequestRoutes();
    });
  }

  void showRequestPointDialog(Point point) {
    _dialogsFactory.showRequestPointDialog(
      onToClicked: () => _requestPointsManager.setToPoint(point),
      onViaClicked: () => _requestPointsManager.setViaPoint(point),
      onFromClicked: () => _requestPointsManager.setFromPoint(point),
    );
  }

  @override
  void dispose() {
    _requestPointsSubscription?.cancel();
  }

  void _listenForRequestRoutes() {
    _requestPointsSubscription?.cancel();
    _requestPointsSubscription =
        _requestPointsManager.requestPoints.listen((points) {
      if (points.isNotEmpty) {
        _navigationManager.requestRoutes(points);
      } else {
        _navigationManager.resetRoutes();
      }
    });
  }
}
