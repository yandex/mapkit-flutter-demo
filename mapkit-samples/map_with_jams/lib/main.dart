import 'package:common/map/flutter_map_widget.dart';
import 'package:common/resources/dimensions.dart';
import 'package:common/resources/theme.dart';
import 'package:common/utils/extension_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:map_with_jams/data/geometry_provider.dart';
import 'package:map_with_jams/traffic/traffic_lights_images_provider.dart';
import 'package:map_with_jams/traffic/traffic_state.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:flutter/widgets.dart' as dart_widgets;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await init.initMapkit(apiKey: dotenv.env["API_KEY"]!);

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

class _MapkitFlutterAppState extends State<MapkitFlutterApp>
    implements TrafficListener {
  TrafficLayer? _trafficLayer;
  TrafficLevel? _trafficLevel;
  TrafficState? _trafficState;

  String _trafficIconPath = TrafficLightsImagesProvider.trafficLightDarkPath;
  String _trafficLevelText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(
              onMapCreated: (mapWindow) {
                mapWindow.map.move(GeometryProvider.startPosition);

                _trafficLayer = mapkit.createTrafficLayer(mapWindow)
                  ..setTrafficVisible(true)
                  ..addTrafficListener(this);

                _updateTrafficLevel();
              },
              onMapDispose: () {
                _trafficLayer?.removeTrafficListener(this);
              },
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: Dimensions.commonPadding,
                      left: Dimensions.commonPadding),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          _trafficLayer?.let((it) {
                            it.setTrafficVisible(!it.isTrafficVisible());
                          });
                          _updateTrafficLevel();
                        },
                        padding: EdgeInsets.zero,
                        minWidth: 0,
                        height: 80.0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: dart_widgets.Image.asset(
                          _trafficIconPath,
                          width: 80.0,
                          height: 80.0,
                        ),
                      ),
                      Text(
                        _trafficLevelText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      )
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

  void _updateTrafficLevel() {
    setState(() {
      var newTrafficLevelText = "";

      if (_trafficLayer?.isTrafficVisible() == false) {
        _trafficIconPath = TrafficLightsImagesProvider.trafficLightDarkPath;
      } else if (_trafficState == TrafficState.loading) {
        _trafficIconPath = TrafficLightsImagesProvider.trafficLightVioletPath;
      } else if (_trafficState == TrafficState.expired) {
        _trafficIconPath = TrafficLightsImagesProvider.trafficLightBluePath;
      } else if (_trafficLevel == null) {
        // state is fresh but region has no data
        _trafficIconPath = TrafficLightsImagesProvider.trafficLightGreyPath;
      } else {
        switch (_trafficLevel?.color) {
          case TrafficColor.Red:
            _trafficIconPath = TrafficLightsImagesProvider.trafficLightRedPath;
          case TrafficColor.Green:
            _trafficIconPath =
                TrafficLightsImagesProvider.trafficLightGreenPath;
          case TrafficColor.Yellow:
            _trafficIconPath =
                TrafficLightsImagesProvider.trafficLightYellowPath;
          default:
            _trafficIconPath = TrafficLightsImagesProvider.trafficLightGreyPath;
        }
        newTrafficLevelText = _trafficLevel?.level.toString() ?? "";
      }
      _trafficLevelText = newTrafficLevelText;
    });
  }

  @override
  void onTrafficChanged(TrafficLevel? trafficLevel) {
    _trafficLevel = trafficLevel;
    _trafficState = TrafficState.ok;
    _updateTrafficLevel();
  }

  @override
  void onTrafficLoading() {
    _trafficLevel = null;
    _trafficState = TrafficState.loading;
    _updateTrafficLevel();
  }

  @override
  void onTrafficExpired() {
    _trafficLevel = null;
    _trafficState = TrafficState.expired;
    _updateTrafficLevel();
  }
}
