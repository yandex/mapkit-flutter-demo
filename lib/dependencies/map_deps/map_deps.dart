import 'package:navikit_flutter_demo/data/camera/camera_manager_impl.dart';
import 'package:navikit_flutter_demo/data/input/map_input_manager_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/navigation_layer_manager_impl.dart';
import 'package:navikit_flutter_demo/data/navigation/style/navigation_style_manager_impl.dart';
import 'package:navikit_flutter_demo/dependencies/disposable_deps.dart';
import 'package:navikit_flutter_demo/domain/camera/camera_manager.dart';
import 'package:navikit_flutter_demo/domain/input/map_input_manager.dart';
import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/navigation/navigation_layer_manager.dart';
import 'package:yandex_maps_navikit/automotive_navigation_style_provider.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';
import 'package:yandex_maps_navikit/road_events_layer_style_provider.dart';

abstract interface class MapDeps implements DisposableDeps {
  MapWindow get mapWindow;
  CameraManager get cameraManager;
  NavigationLayerManager get navigationLayerManager;
  MapInputManager get mapInputManager;
}

final class MapDepsScope implements MapDeps {
  late final Navigation _navigation;
  late final domain.LocationManager _locationManager;

  final NavigationStyleProvider _automotiveNavigationStyleProvider =
      AutomotiveNavigationStyleProvider();
  final RoadEventsLayerStyleProvider _roadEventsDefaultStyleProvider =
      RoadEventsLayerDefaultStyleProvider();

  late final _navigationStyleManager = NavigationStyleManagerImpl(
    _automotiveNavigationStyleProvider,
  );

  MapDepsScope(this.mapWindow, this._navigation, this._locationManager);

  @override
  late final MapWindow mapWindow;

  @override
  late final cameraManager = CameraManagerImpl(mapWindow, _locationManager);

  @override
  late final navigationLayerManager = NavigationLayerManagerImpl(
    mapWindow,
    _roadEventsDefaultStyleProvider,
    _navigationStyleManager,
    _navigation,
  );

  @override
  late final mapInputManager = MapInputManagerImpl();

  @override
  void disposeAll() {
    cameraManager.dispose();
    navigationLayerManager.dispose();
    mapInputManager.dispose();
  }
}
