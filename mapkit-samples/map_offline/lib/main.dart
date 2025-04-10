import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_offline/common/managers/offline_cache_error/offline_cache_error_manager.dart';
import 'package:map_offline/common/managers/region_list_updates/region_list_updates_manager.dart';
import 'package:map_offline/common/managers/region_state_updates/region_state_updates_manager.dart';
import 'package:map_offline/features/region/managers/region_manager.dart';
import 'package:map_offline/features/region/widget/region_bottomsheet.dart';
import 'package:map_offline/features/regions_list/managers/region_list_manager.dart';
import 'package:map_offline/features/regions_list/state/region_list_ui_state.dart';
import 'package:map_offline/features/regions_list/widgets/regions_list_bottomsheet.dart';
import 'package:map_offline/features/settings/managers/settings_manager.dart';
import 'package:map_offline/features/settings/state/set_cache_path_state.dart';
import 'package:map_offline/features/settings/widgets/settings_bottomsheet.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';

import 'features/settings/state/move_cache_state.dart';
import 'features/settings/state/settings_ui_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /**
   * Replace "your_api_key" with a valid developer key.
   */
  init.initMapkit(apiKey: "your_api_key");

  final offlineCacheManager = mapkit.offlineCacheManager;
  final settingsManager = SettingsManager(offlineCacheManager);

  const textSelectionTheme = TextSelectionThemeData(
      selectionColor: Colors.lightBlueAccent,
      selectionHandleColor: Colors.deepPurpleAccent
  );
  const textSelectionIosTheme = CupertinoThemeData(
    primaryColor: Colors.deepPurpleAccent
  );

  await settingsManager.initStorage();

  runApp(
    MaterialApp(
      theme: MapkitFlutterTheme.lightTheme.copyWith(
        textSelectionTheme: textSelectionTheme,
        cupertinoOverrideTheme: textSelectionIosTheme,
      ),
      darkTheme: MapkitFlutterTheme.darkTheme.copyWith(
        textSelectionTheme: textSelectionTheme,
        cupertinoOverrideTheme: textSelectionIosTheme,
      ),
      themeMode: ThemeMode.system,
      home: MapkitFlutterApp(offlineCacheManager, settingsManager),
    ),
  );
}

class MapkitFlutterApp extends StatefulWidget {
  final OfflineCacheManager offlineCacheManager;
  final SettingsManager settingsManager;

  const MapkitFlutterApp(
    this.offlineCacheManager,
    this.settingsManager, {
    super.key,
  });

  @override
  State<MapkitFlutterApp> createState() => _MapkitFlutterAppState();
}

class _MapkitFlutterAppState extends State<MapkitFlutterApp> {
  final _regionsTextFieldController = TextEditingController();
  final _settingsTextFieldController = TextEditingController();
  final _globalKey = GlobalKey<ScaffoldState>();

  late final MapWindow _mapWindow;

  late final _regionListUpdatesManager = RegionListUpdatesManager(
    widget.offlineCacheManager,
  );
  late final _regionStateUpdatesManager = RegionStateUpdatesManager(
    widget.offlineCacheManager,
  );

  late final _regionListManager = RegionListManager(
    widget.offlineCacheManager,
    _regionListUpdatesManager,
    _regionStateUpdatesManager,
  );

  late final _regionManager = RegionManager(
    widget.offlineCacheManager,
    _regionListUpdatesManager,
    _regionStateUpdatesManager,
  );

  late final _offlineCacheErrorManager = OfflineCacheErrorManager(
    widget.offlineCacheManager,
    () => _globalKey.currentContext,
  );

  StreamSubscription<MoveCacheState>? _moveCacheSubscription;
  StreamSubscription<SetCachePathState>? _setCachePathSubscription;
  StreamSubscription<RegionListUiState>? _regionListUiStateSubscription;
  StreamSubscription<SettingsUiState>? _settingsUiStateSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(
              onMapCreated: _setupMap,
              onMapDispose: _disposeMap,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10.0,
                    children: [
                      SimpleButton(
                        text: "Settings",
                        onPressed: () => _showSettingsBottomSheet(context),
                      ),
                      SimpleButton(
                        text: "Regions list",
                        onPressed: () => _showRegionsListBottomSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupMap(MapWindow mapWindow) {
    _mapWindow = mapWindow;
    _regionListUpdatesManager.startListening();
    _regionStateUpdatesManager.startListening();
    _offlineCacheErrorManager.startListening();
    widget.settingsManager.startListening();

    _moveCacheSubscription =
        widget.settingsManager.moveCacheState.listen((moveCacheState) {
      switch (moveCacheState) {
        case final MoveCacheCompleted _:
          showSnackBar(
            context,
            "Caches moved to ${_settingsTextFieldController.text}",
          );
        case final MoveCacheError state:
          showSnackBar(
            context,
            "Error on moving cache: ${state.error}",
          );
        case _:
      }
    });

    _setCachePathSubscription =
        widget.settingsManager.setCachePathState.listen((setCachePathState) {
      switch (setCachePathState) {
        case final SetCachePathSuccess _:
          showSnackBar(
            context,
            "Successfully set path to ${_settingsTextFieldController.text}",
          );
        case final SetCachePathError state:
          showSnackBar(
            context,
            "Error on setting path: ${state.error}",
          );
        case _:
      }
    });
  }

  void _disposeMap() {
    _moveCacheSubscription?.cancel();
    _setCachePathSubscription?.cancel();
    _regionListUiStateSubscription?.cancel();
    _settingsUiStateSubscription?.cancel();
    _regionListUpdatesManager.dispose();
    _regionStateUpdatesManager.dispose();
    _offlineCacheErrorManager.dispose();
  }

  void _showRegionsListBottomSheet(BuildContext context) {
    _regionListUiStateSubscription ??= _regionListManager.uiState.connect();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: _regionListManager.uiState,
          builder: (context, snapshot) {
            final uiState = snapshot.data;

            _regionsTextFieldController.text = uiState?.searchQuery ?? "";

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              builder: (_, scrollController) {
                return RegionsListBottomSheet(
                  scrollController,
                  regionItems: uiState?.regions ?? [],
                  textEditingController: _regionsTextFieldController,
                  onTextChanged: (text) =>
                      _regionListManager.searchRegions(text),
                  onSubmitted: (text) => _regionListManager.searchRegions(text),
                  onClearButtonTapped: () =>
                      _regionListManager.searchRegions(""),
                  onRegionTapped: (regionId) {
                    _showRegionBottomSheet(context, regionId);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRegionBottomSheet(BuildContext context, int regionId) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: _regionManager.uiState(regionId),
          builder: (context, snapshot) {
            final uiState = snapshot.data;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              builder: (_, scrollController) {
                if (uiState != null) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: RegionsBottomSheet(
                      regionUiState: uiState,
                      onShowButtonTap: () {
                        _moveCameraToRegionCenter(uiState.center);
                        // close both bottom sheets
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onStartDownloadButtonTapped: () {
                        final isStarted =
                            _regionManager.startDownload(uiState.id);
                        if (!isStarted) {
                          showSnackBar(
                            context,
                            "Not enough available space on device to download region with ${uiState.id} id",
                          );
                        }
                      },
                      onStopDownloadButtonTapped: () {
                        _regionManager.stopDownload(uiState.id);
                      },
                      onPauseDownloadButtonTapped: () {
                        _regionManager.pauseDownload(uiState.id);
                      },
                      onDropDownloadButtonTapped: () {
                        _regionManager.drop(uiState.id);
                      },
                    )
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Didn't find any data about this region :(",
                            style: Theme.of(context).textTheme.labelLarge,
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    _settingsUiStateSubscription ??= widget.settingsManager.uiState.connect();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return StreamBuilder(
          stream: widget.settingsManager.uiState,
          builder: (context, snapshot) {
            final uiState = snapshot.data;

            if (uiState != null) {
              _settingsTextFieldController.text = uiState.cachesPath;

              return Scaffold(
                backgroundColor: Colors.transparent,
                body: SettingsBottomSheet(
                  _settingsTextFieldController,
                  settingsUiState: uiState,
                  onAllowCellularNetworkButtonTapped: (checked) {
                    widget.settingsManager
                        .setUseCellularNetwork(checked == true);
                  },
                  onAutoUpdateButtonTapped: (checked) {
                    widget.settingsManager
                        .setAutoUpdateEnabled(checked == true);
                  },
                  onShowCacheSizeButtonTapped: () {
                    widget.settingsManager.computeCacheSize((size) {
                      showSnackBar(
                        bottomSheetContext,
                        "Cache size: $size bytes",
                      );
                    });
                  },
                  onClearCacheButtonTapped: () {
                    widget.settingsManager.clearCache(() {
                      showSnackBar(
                        bottomSheetContext,
                        "All caches were cleared",
                      );
                    });
                  },
                  onMoveCacheButtonTapped: () {
                    widget.settingsManager
                        .moveCache(_settingsTextFieldController.text);
                  },
                  onSwitchPathButtonTapped: () {
                    widget.settingsManager
                        .setCachePath(_settingsTextFieldController.text);
                  },
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Something went wrong :(",
                        style: Theme.of(context).textTheme.labelLarge,
                      )
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _moveCameraToRegionCenter(Point point) {
    _mapWindow.map.let((map) {
      final cameraPosition = CameraPosition(
        point,
        zoom: 10.0,
        azimuth: map.cameraPosition.azimuth,
        tilt: map.cameraPosition.tilt,
      );

      map.moveWithAnimation(
        cameraPosition,
        CameraAnimationProvider.defaultCameraAnimation,
      );
    });
  }
}
