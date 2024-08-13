import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/core/resources/dimensions.dart';
import 'package:navikit_flutter_demo/dependencies/application_deps/application_deps_provider.dart';
import 'package:navikit_flutter_demo/dependencies/map_deps/map_deps.dart';
import 'package:navikit_flutter_demo/domain/camera/camera_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/model/guidance_model_provider.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/ui/guidance_panel.dart';
import 'package:navikit_flutter_demo/features/location_panel/models/camera/camera_model_provider.dart';
import 'package:navikit_flutter_demo/features/location_panel/models/location/location_model_provider.dart';
import 'package:navikit_flutter_demo/features/location_panel/ui/location_panel.dart';
import 'package:navikit_flutter_demo/features/map_screen/managers/map_screen_manager.dart';
import 'package:navikit_flutter_demo/features/map_screen/ui/buttons/find_me_button.dart';
import 'package:navikit_flutter_demo/features/map_screen/ui/buttons/map_control_button.dart';
import 'package:navikit_flutter_demo/features/map_screen/ui/buttons/overview_route_button.dart';
import 'package:navikit_flutter_demo/features/route_variants_panel/managers/route_variants_screen_manager.dart';
import 'package:navikit_flutter_demo/features/route_variants_panel/model/route_variants_screen_model_provider.dart';
import 'package:navikit_flutter_demo/features/route_variants_panel/ui/route_variants_panel.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/mapkit_factory.dart';
import 'package:yandex_maps_navikit/navigation.dart';
import 'package:yandex_maps_navikit/yandex_map.dart';

final class FlutterMapWidget extends StatefulWidget {
  final void Function(BuildContext) showSettingsBottomsheet;

  const FlutterMapWidget({
    super.key,
    required this.showSettingsBottomsheet,
  });

  @override
  State<FlutterMapWidget> createState() => FlutterMapWidgetState();
}

final class FlutterMapWidgetState extends State<FlutterMapWidget> {
  late final AppLifecycleListener _lifecycleListener;
  late final MapDeps mapDeps;

  late final routeVariantsScreenManager = RouteVariantsScreenManager(
    navigationManager,
    requestPointsManager,
    alertsFactory,
  );

  late final mapTapScreenManager = MapTapScreenManager(
    navigationManager,
    mapDeps.mapInputManager,
    routeVariantsScreenManager,
  );

  late final locationModelProvider = LocationModelProvider(locationManager);
  late final cameraModelProvider = CameraModelProvider(mapDeps.cameraManager);
  late final routeVariantsModelProvider = RouteVariantsScreenModelProvider(
    routeVariantsScreenManager.isRouteVariantsVisible,
  );
  late final guidanceModelProvider = GuidanceModelProvider(
    locationManager,
    navigationManager,
    simulationManager,
  );

  bool _isMapkitActive = false;
  bool _isMapCreated = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SafeArea(
          top: false,
          child: YandexMap(
            onMapCreated: _onMapCreated,
            platformViewType: PlatformViewType.Hybrid,
          ),
        ),
        if (_isMapCreated) ...[
          Positioned(
            top: 0.0,
            left: 0.0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.panelPadding,
                  left: Dimensions.panelPadding,
                ),
                child: LocationPanel(
                  backgroundColor:
                      Theme.of(context).colorScheme.background.withOpacity(0.8),
                  locationModel: locationModelProvider.model,
                  cameraModel: cameraModelProvider.model,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0.0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  right: Dimensions.commonPadding,
                  bottom: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 60.0
                      : 0.0,
                ),
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: Dimensions.commonSpacing,
                  children: [
                    MapControlButton(
                      icon: Icons.add,
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      onPressed: () {
                        mapDeps.cameraManager.changeZoomByStep(ZoomStep.plus);
                      },
                    ),
                    MapControlButton(
                      icon: Icons.remove,
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      onPressed: () {
                        mapDeps.cameraManager.changeZoomByStep(ZoomStep.minus);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: Dimensions.commonPadding,
                        bottom: Dimensions.commonPadding,
                      ),
                      child: Wrap(
                        spacing: Dimensions.commonSpacing,
                        children: [
                          OverviewRouteButton(
                            guidanceModel: guidanceModelProvider.model,
                            onPressed: () {
                              mapDeps.navigationLayerManager.cameraMode =
                                  CameraMode.Overview;
                            },
                          ),
                          FindMeButton(
                            guidanceModel: guidanceModelProvider.model,
                            defaultAction: () {
                              mapDeps.cameraManager.moveCameraToUserLocation();
                            },
                            actionInGuidanceMode: () {
                              mapDeps.navigationLayerManager.cameraMode =
                                  CameraMode.Following;
                            },
                          ),
                          // MapControlButton(
                          //   icon: Icons.settings,
                          //   backgroundColor:
                          //       Theme.of(context).colorScheme.onSecondary,
                          //   onPressed: () {
                          //     widget.showSettingsBottomsheet(context);
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                  RouteVariantsPanel(
                    routeVariantsScreenModel: routeVariantsModelProvider.model,
                    onGoClicked: () => _startGuidance(),
                    onCancelClicked: () => requestPointsManager.resetPoints(),
                  ),
                  GuidancePanel(
                    guidanceModel: guidanceModelProvider.model,
                    closeGuidanceAction: _stopGuidance,
                  )
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _startMapkit();
    _clearNavigationSerialization();

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _startMapkit();
        _setMapTheme();
      },
      onInactive: () {
        _stopMapkit();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _disposeAll();
    super.dispose();
  }

  void _startMapkit() {
    if (!_isMapkitActive) {
      _isMapkitActive = true;
      mapkit.onStart();
    }
  }

  void _stopMapkit() {
    if (_isMapkitActive) {
      _isMapkitActive = false;
      mapkit.onStop();
    }
  }

  void _onMapCreated(MapWindow window) {
    mapDeps = MapDepsScope(
      window,
      navigationHolder.navigation,
      locationManager,
    );

    setState(() {
      _isMapCreated = true;
    });

    _setupLocationManager();
    _setupNavigationLayerManager();
    _setupNavigationManager();
    _setupCameraManager();
    _setupMapTapScreenManager();

    window.let((it) {
      it.map.addInputListener(mapDeps.mapInputManager);
      it.map.logo.setAlignment(
        const LogoAlignment(
          LogoHorizontalAlignment.Left,
          LogoVerticalAlignment.Bottom,
        ),
      );
    });

    _setMapTheme();
  }

  void _setMapTheme() {
    mapDeps.mapWindow.map.nightModeEnabled =
        Theme.of(context).brightness == Brightness.dark;
  }

  void _setupNavigationLayerManager() {
    mapDeps.navigationLayerManager.initIfNeeded();
  }

  void _setupLocationManager() {
    locationManager.startListening();
  }

  void _setupCameraManager() {
    mapDeps.cameraManager.start();
  }

  void _setupNavigationManager() {
    navigationManager.startListening();
  }

  void _setupMapTapScreenManager() {
    mapTapScreenManager.startListeningForTaps();
  }

  void _startGuidance() {
    final route = mapDeps.navigationLayerManager.selectedRoute;
    if (route != null && !navigationManager.isGuidanceActive) {
      navigationManager.startGuidance(route);
    }
  }

  void _stopGuidance() {
    alertsFactory.showCancelGuidanceDialog(primaryAction: () {
      navigationManager.stopGuidance();
    });
  }

  void _disposeAll() {
    mapDeps.mapWindow.map.removeInputListener(mapDeps.mapInputManager);
    mapTapScreenManager.dispose();
    routeVariantsScreenManager.dispose();
    mapDeps.disposeAll();
  }

  void _clearNavigationSerialization() {
    if (settingsManager.restoreGuidanceState.value) {
      settingsManager.serializedNavigation.setValue("");
    }
  }
}
