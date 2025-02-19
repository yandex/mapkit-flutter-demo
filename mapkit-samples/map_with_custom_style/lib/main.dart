import 'dart:async';

import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';

Future<String> _readJsonFile(String filePath) async {
  return await rootBundle.loadString(filePath);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /**
   * Replace "your_api_key" with a valid developer key.
   */
  await init.initMapkit(apiKey: "your_api_key");
  final mapStyleJson = await _readJsonFile("assets/map_style.json");

  runApp(
    MaterialApp(
      theme: MapkitFlutterTheme.lightTheme,
      darkTheme: MapkitFlutterTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: MapkitFlutterApp(mapStyleJson: mapStyleJson),
    ),
  );
}

class MapkitFlutterApp extends StatefulWidget {
  final String mapStyleJson;

  const MapkitFlutterApp({super.key, required this.mapStyleJson});

  @override
  State<MapkitFlutterApp> createState() => _MapkitFlutterAppState();
}

class _MapkitFlutterAppState extends State<MapkitFlutterApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(onMapCreated: _setupMap),
          ],
        ),
      ),
    );
  }

  void _setupMap(MapWindow mapWindow) {
    // you can create your own style here https://yandex.com/maps-api/map-style-editor
    mapWindow.map.setMapStyle(widget.mapStyleJson);
  }
}
