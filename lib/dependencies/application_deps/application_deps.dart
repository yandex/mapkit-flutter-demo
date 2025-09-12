import 'package:flutter/widgets.dart';
import 'package:navikit_flutter_demo/data/alerts/dialogs/dialog_provider_impl.dart';
import 'package:navikit_flutter_demo/data/alerts/dialogs/dialogs_factory_impl.dart';
import 'package:navikit_flutter_demo/data/alerts/toasts/snackbar_factory_impl.dart';
import 'package:navikit_flutter_demo/data/location/location_manager_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/navigation_holder_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/navigation_manager_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/navigation_suspender_manager_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/serialization/navigation_serializer_impl.dart';
import 'package:navikit_flutter_demo/data/permissions/permission_manager_impl.dart';
import 'package:navikit_flutter_demo/data/route/request_points_manager_impl.dart';
import 'package:navikit_flutter_demo/data/settings/settings_manager_impl.dart';
import 'package:navikit_flutter_demo/data/simulation/simulation_manager_impl.dart';
import 'package:navikit_flutter_demo/data/storage/key_value_storage_impl.dart';
import 'package:navikit_flutter_demo/dependencies/disposable_deps.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialogs_factory.dart';
import 'package:navikit_flutter_demo/domain/alerts/snackbars/snackbar_factory.dart';
import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/navigation/navigation_holder.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_suspender_manager.dart';
import 'package:navikit_flutter_demo/domain/permissions/permission_manager.dart';
import 'package:navikit_flutter_demo/domain/route/request_points_manager.dart';
import 'package:navikit_flutter_demo/domain/settings/settings_manager.dart';
import 'package:navikit_flutter_demo/domain/simulation/simulation_manager.dart';

abstract interface class ApplicationDeps implements DisposableDeps {
  NavigationHolder get navigationHolder;
  domain.LocationManager get locationManager;
  DialogsFactory get alertsFactory;
  SnackBarFactory get snackBarFactory;
  PermissionManager get permissionManager;
  RequestPointsManager get requestPointsManager;
  NavigationManager get navigationManager;
  SimulationManager get simulationManager;
  NavigationSuspenderManager get navigationSuspenderManager;
  SettingsManager get settingsManager;

  GlobalKey get globalKey;

  Future<void> initDependencies();
}

final class ApplicationDepsScope implements ApplicationDeps {
  late final _keyValueStorage = KeyValueStorageImpl();
  late final _navigationSerializer = NavigationSerializerImpl(settingsManager);
  late final _dialogProvider = DialogProviderImpl(globalKey);

  @override
  late final globalKey = GlobalKey();

  @override
  late final navigationHolder = NavigationHolderImpl(
    settingsManager,
    _navigationSerializer,
    snackBarFactory,
  );

  @override
  late final locationManager = LocationManagerImpl(navigationHolder.navigation);

  @override
  late final alertsFactory = DialogsFactoryImpl(_dialogProvider);

  @override
  late final snackBarFactory = SnackBarFactoryImpl(globalKey);

  @override
  late final permissionManager = PermissionManagerImpl(alertsFactory);

  @override
  late final requestPointsManager = RequestPointsManagerImpl(locationManager);

  @override
  late final navigationManager = NavigationManagerImpl(
    requestPointsManager,
    simulationManager,
    navigationHolder.navigation,
    snackBarFactory,
  );

  @override
  late final simulationManager = SimulationManagerImpl();

  @override
  late final navigationSuspenderManager = NavigationSuspenderManagerImpl(
    navigationManager,
  );

  @override
  late final settingsManager = SettingsManagerImpl(_keyValueStorage);

  @override
  Future<void> initDependencies() async {
    // Initialize there dependencies that must be initialized before widgets are rendered
    final futures = [
      _keyValueStorage.initStorage(),
    ];
    Future.wait(futures);
  }

  @override
  void disposeAll() {
    locationManager.dispose();
    requestPointsManager.dispose();
    navigationManager.dispose();
    simulationManager.dispose();
  }
}
