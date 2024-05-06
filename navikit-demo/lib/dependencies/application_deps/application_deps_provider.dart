import 'package:navikit_flutter_demo/dependencies/application_deps/application_deps.dart';

final ApplicationDeps _applicationDepsScope = ApplicationDepsScope();

final globalKey = _applicationDepsScope.globalKey;

final navigationHolder = _applicationDepsScope.navigationHolder;

final locationManager = _applicationDepsScope.locationManager;

final alertsFactory = _applicationDepsScope.alertsFactory;

final permissionManager = _applicationDepsScope.permissionManager;

final requestPointsManager = _applicationDepsScope.requestPointsManager;

final navigationManager = _applicationDepsScope.navigationManager;

final simulationManager = _applicationDepsScope.simulationManager;

final navigationSuspenderManager =
    _applicationDepsScope.navigationSuspenderManager;

final settingsManager = _applicationDepsScope.settingsManager;

Future<void> initApplicationDeps() async {
  await _applicationDepsScope.initDependencies();
}

void disposeApplicationDeps() => _applicationDepsScope.disposeAll();
