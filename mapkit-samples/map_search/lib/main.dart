import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:map_search/data/geometry_provider.dart';
import 'package:map_search/features/details/managers/details_bottomsheet_manager.dart';
import 'package:map_search/features/details/state/details_bottomsheet_ui_state.dart';
import 'package:map_search/features/details/widgets/details_bottomsheet.dart';
import 'package:map_search/features/search/managers/map_search_manager.dart';
import 'package:map_search/features/search/state/map_search_state.dart';
import 'package:map_search/features/search/state/search_bottomsheet_ui_state.dart';
import 'package:map_search/features/search/state/search_state.dart';
import 'package:map_search/features/search/state/suggest_state.dart';
import 'package:map_search/features/search/widgets/search_bottomsheet.dart';
import 'package:yandex_maps_mapkit/image.dart' as image_provider;
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await init.initMapkit(apiKey: dotenv.env["API_KEY"]!);

  const textSelectionTheme = TextSelectionThemeData(
      selectionColor: Colors.lightBlueAccent,
      selectionHandleColor: Colors.deepPurpleAccent
  );
  const textSelectionIosTheme = CupertinoThemeData(
      primaryColor: Colors.deepPurpleAccent
  );

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
      home: const MapkitFlutterApp(),
    ),
  );
}

class MapkitFlutterApp extends StatefulWidget {
  const MapkitFlutterApp({super.key});

  @override
  State<MapkitFlutterApp> createState() => _MapkitFlutterAppState();
}

class _MapkitFlutterAppState extends State<MapkitFlutterApp> {
  final _searchResultImageProvider =
      image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/search_result.png"));
  final _textFieldController = TextEditingController();

  final _mapManager = MapSearchManager();
  final _detailsBottomSheetManager = DetailsBottomSheetManager();

  late final MapObjectCollection _searchResultPlacemarksCollection;

  late final _mapWindowSizeChangedListener = MapSizeChangedListenerImpl(
      onMapWindowSizeChange: (_, __, ___) => _updateFocusRect());

  late final _cameraListener = CameraPositionListenerImpl(
    (_, __, cameraUpdateReason, ___) {
      // Updating current visible region to apply new search on map moved by user gestures.
      if (cameraUpdateReason == CameraUpdateReason.Gestures) {
        _mapWindow
            ?.let((it) => _mapManager.setVisibleRegion(it.map.visibleRegion));
      }
    },
  );

  late final _searchResultPlacemarkTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (mapObject, _) {
      // Show details bottom sheet on placemark tap
      final successSearchState = _mapManager
          .mapSearchState.valueOrNull?.searchState
          .castOrNull<SearchSuccess>();

      final point = mapObject.castOrNull<PlacemarkMapObject>()?.geometry;
      final tappedGeoObject =
          successSearchState?.placemarkPointToGeoObject[point];

      if (tappedGeoObject != null) {
        final detailsBottomSheetUiState =
            _detailsBottomSheetManager.uiState(tappedGeoObject);
        _showDetailsBottomSheet(context, detailsBottomSheetUiState);
      }
      return true;
    },
  );

  MapWindow? _mapWindow;

  StreamSubscription<MapSearchState>? _mapSearchSubscription;
  StreamSubscription<void>? _searchSubscription;
  StreamSubscription<void>? _suggestSubscription;

  @override
  void dispose() {
    _mapManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(
              onMapCreated: _setupMap,
              onMapDispose: () {
                _mapWindow
                    ?.removeSizeChangedListener(_mapWindowSizeChangedListener);
                _mapWindow?.map.removeCameraListener(_cameraListener);
                _mapSearchSubscription?.cancel();
                _searchSubscription?.cancel();
                _suggestSubscription?.cancel();
              },
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SimpleButton(
                    text: "Show search",
                    onPressed: () => _showSearchBottomSheet(context),
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
    _searchResultPlacemarksCollection =
        mapWindow.map.mapObjects.addCollection();

    mapWindow.addSizeChangedListener(_mapWindowSizeChangedListener);

    mapWindow.map
      ..move(GeometryProvider.startPosition)
      ..addCameraListener(_cameraListener);

    _mapManager.setVisibleRegion(mapWindow.map.visibleRegion);

    _mapSearchSubscription = _mapManager.mapSearchState.listen((uiState) {
      if (uiState.suggestState is SuggestError) {
        showSnackBar(context, "Suggest error, check your network connection");
      }

      final searchState = uiState.searchState;

      if (searchState is SearchSuccess) {
        final searchItems = searchState.items;

        _updateSearchResponsePlacemarks(searchItems);

        if (searchState.shouldZoomToItems) {
          _focusCamera(
            searchItems.map((it) => it.point),
            searchState.itemsBoundingBox,
          );
        }
      } else if (searchState is SearchOff) {
        _searchResultPlacemarksCollection.clear();
      } else if (searchState is SearchError) {
        showSnackBar(context, "Search error, check your network connection");
      }
    });

    _searchSubscription = _mapManager.subscribeForSearch().listen((_) {});
    _suggestSubscription = _mapManager.subscribeForSuggest().listen((_) {});
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: _mapManager.mapSearchState.toBottomSheetUiState(),
          builder: (context, snapshot) {
            final uiState = snapshot.data;

            _textFieldController.text = uiState?.searchQuery ?? "";

            return SearchBottomSheet(
              suggestItems: uiState?.suggestItems ?? [],
              searchAndSuggestStatus: uiState?.searchAndSuggestStatus ?? "",
              textEditingController: _textFieldController,
              isSearchButtonEnabled: uiState?.isSearchButtonEnabled == true,
              isResetButtonEnabled: uiState?.isResetButtonEnabled == true,
              isCategoryButtonsVisible:
                  uiState?.isCategoryButtonsVisible == true,
              isTextFieldEnabled: uiState?.isTextFieldEnabled == true,
              onTextChanged: (text) {
                if (text.isNotBlank &&
                    text !=
                        _mapManager.mapSearchState.valueOrNull?.searchQuery) {
                  _mapManager.setQueryText(text);
                }
              },
              onSubmitted: (text) => _mapManager.startSearch(text),
              onSearchButtonTapped: () {
                _mapManager.startSearch();
                Navigator.pop(context);
              },
              onClearButtonTapped: () => _mapManager.setQueryText(""),
              onResetButtonTapped: () => _mapManager.reset(),
              onSearchCoffeeButtonTapped: () {
                _mapManager.setQueryText("Coffee");
              },
              onSearchMallButtonTapped: () {
                _mapManager.setQueryText("Mall");
              },
              onSearchHotelButtonTapped: () {
                _mapManager.setQueryText("Hotel");
              },
            );
          },
        );
      },
    );
  }

  void _showDetailsBottomSheet(
    BuildContext context,
    DetailsBottomSheetUiState uiState,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DetailsBottomSheet(uiState: uiState),
    );
  }

  void _updateFocusRect() {
    const horizontalMargin = 12.0;
    const verticalMargin = 24.0;

    _mapWindow?.let((it) {
      it.focusRect = ScreenRect(
        const ScreenPoint(x: horizontalMargin, y: verticalMargin),
        ScreenPoint(
          x: it.width() - horizontalMargin,
          y: it.height() - verticalMargin,
        ),
      );
    });
  }

  void _updateSearchResponsePlacemarks(List<SearchResponseItem> items) {
    _mapWindow?.map.let((map) {
      _searchResultPlacemarksCollection.clear();

      items.forEach((item) {
        _searchResultPlacemarksCollection.addPlacemark()
          ..geometry = item.point
          ..setIcon(_searchResultImageProvider)
          ..setIconStyle(const IconStyle(scale: 1.5))
          ..addTapListener(_searchResultPlacemarkTapListener);
      });
    });
  }

  void _focusCamera(Iterable<Point> points, BoundingBox boundingBox) {
    if (points.isEmpty) {
      return;
    }

    _mapWindow?.map.let((map) {
      final cameraPosition = points.length == 1
          ? CameraPosition(
              points.first,
              zoom: map.cameraPosition.zoom,
              azimuth: map.cameraPosition.azimuth,
              tilt: map.cameraPosition.tilt,
            )
          : map
              .cameraPositionForGeometry(Geometry.fromBoundingBox(boundingBox));

      map.moveWithAnimation(
        cameraPosition,
        CameraAnimationProvider.defaultCameraAnimation,
      );
    });
  }
}
