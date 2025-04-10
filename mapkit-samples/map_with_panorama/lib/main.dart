import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:map_with_panorama/listeners/layers_geo_object_tap_listener.dart';
import 'package:map_with_panorama/utils/extension_utils.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/places.dart';
import 'package:yandex_maps_mapkit/runtime.dart';
import 'package:yandex_maps_mapkit/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /**
   * Replace "your_api_key" with a valid developer key.
   */
  init.initMapkit(apiKey: "your_api_key");

  runApp(
    MaterialApp(
      theme: MapkitFlutterTheme.lightTheme,
      darkTheme: MapkitFlutterTheme.darkTheme,
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

class _MapkitFlutterAppState extends State<MapkitFlutterApp> with WidgetsBindingObserver {
  static const _startPosition = CameraPosition(
    Point(latitude: 55.751244, longitude: 37.618423),
    zoom: 15.0,
    azimuth: 0.0,
    tilt: 0.0,
  );

  late final _mapInputListener = MapInputListenerImpl(
    onMapTapCallback: (map, point) {
      _searchSession = _panoramaService.findNearest(
        point,
        _panoramaSearchListener,
      );
    },
    onMapLongTapCallback: (_, __) {},
  );

  late final _geoObjectTapListener = LayersGeoObjectTapListenerImpl(
    onObjectTapped: (event) {
      final geoObject = event.geoObject;
      final airshipTapInto = geoObject.airshipTapInfo;
      final point = geoObject.point;

      if (airshipTapInto != null && point != null) {
        _navigateToPanorama(airshipTapInto.panoramaId);
        return true;
      }
      return false;
    },
  );

  late final _panoramaSearchListener = PanoramaServiceSearchListener(
    onPanoramaSearchResult: _navigateToPanorama,
    onPanoramaSearchError: (error) {
      String errorMessage = switch (error) {
        final NotFoundError _ => "Not found",
        final RemoteError _ => "Remote server error",
        final NetworkError _ => "Network error",
        _ => "Unknown error",
      };
      showSnackBar(context, errorMessage);
    },
  );

  late final PanoramaService _panoramaService;

  PanoramaServiceSearchSession? _searchSession;
  MapWindow? _mapWindow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(
              onMapCreated: _setupMap,
              onMapDispose: _onMapDispose,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }

  void _setupMap(MapWindow mapWindow) {
    _mapWindow = mapWindow;
    mapWindow.map.move(_startPosition);

    mapWindow.map.addInputListener(_mapInputListener);
    mapWindow.map.addTapListener(_geoObjectTapListener);

    _panoramaService = PlacesFactory.instance.createPanoramaService();

    PlacesFactory.instance.createPanoramaLayer(mapWindow)
      ..setStreetPanoramaVisible(true)
      ..setAirshipPanoramaVisible(true);
  }

  void _onMapDispose() {
    _mapWindow?.map.removeInputListener(_mapInputListener);
    _mapWindow?.map.removeTapListener(_geoObjectTapListener);
    _mapWindow = null;
  }

  void _navigateToPanorama(String panoramaId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PanoramaWidget(
            onPanoramaCreated: (panoramaPlayer) {
              panoramaPlayer
                ..openPanorama(panoramaId)
                ..enableMove()
                ..enableRotation()
                ..enableZoom()
                ..enableMarkers()
                ..enableCompanies()
                ..enableLoadingWheel();
            },
            platformViewType: PlatformViewType.Hybrid,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.ease;
          final tween = Tween(begin: 0.0, end: 1.0);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return FadeTransition(
            opacity: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
