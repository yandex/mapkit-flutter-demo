import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:map_objects/data/geometry_provider.dart';
import 'package:map_objects/listeners/cluster_listener.dart';
import 'package:map_objects/listeners/cluster_tap_listener.dart';
import 'package:map_objects/listeners/map_object_drag_listener.dart';
import 'package:map_objects/listeners/map_object_visitor.dart';
import 'package:map_objects/utils/color_utils.dart';
import 'package:map_objects/widgets/cluster_widget.dart';
import 'package:yandex_maps_mapkit/image.dart' as image_provider;
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;
import 'package:yandex_maps_mapkit/ui_view.dart';

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

class _MapkitFlutterAppState extends State<MapkitFlutterApp> {
  static const _clusterRadius = 60.0;
  static const _clusterMinZoom = 15;

  final _indexToPlacemarkType = <int, PlacemarkType>{};

  final _placemarkTypeToImageProvider =
      <PlacemarkType, image_provider.ImageProvider>{
    PlacemarkType.green: image_provider.ImageProvider.fromImageProvider(
      const AssetImage("assets/pin_green.png"),
    ),
    PlacemarkType.yellow: image_provider.ImageProvider.fromImageProvider(
      const AssetImage("assets/pin_yellow.png"),
    ),
    PlacemarkType.red: image_provider.ImageProvider.fromImageProvider(
      const AssetImage("assets/pin_red.png"),
    ),
  };

  late final mapkit.MapObjectCollection _mapObjectCollection;
  late final mapkit.ClusterizedPlacemarkCollection _clusterizedCollection;

  late final _mapWindowSizeChangedListener = MapSizeChangedListenerImpl(
    onMapWindowSizeChange: (_, __, ___) => _updateFocusRect(),
  );

  late final _polylineTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (mapObject, point) {
      if (mapObject is mapkit.PolylineMapObject) {
        final color = ColorUtils.polylineColor;
        mapObject.setStrokeColor(color);
        showSnackBar(context, "Tapped the polyline, change color");
      }
      return true;
    },
  );

  late final _circleTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (mapObject, point) {
      if (mapObject is mapkit.CircleMapObject) {
        final circle = GeometryProvider.circle;
        mapObject.geometry = circle;
        showSnackBar(
          context,
          "Tapped the circle, the new radius: ${circle.radius}",
        );
      }
      return true;
    },
  );

  late final _placemarkTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (mapObject, _) {
      final placemarkPoint =
          mapObject.castOrNull<mapkit.PlacemarkMapObject>()?.geometry;

      final placemarkType = _indexToPlacemarkType[mapObject.userData];

      showSnackBar(
        context,
        "Tapped the placemark:\n$placemarkPoint, $placemarkType",
      );
      return true;
    },
  );

  late final _pinDragListener = MapObjectDragListenerImpl(
    onMapObjectDragStartCallback: (mapObject) => showSnackBar(
      context,
      "Start drag event",
    ),
    onMapObjectDragCallback: (_, __) {},
    onMapObjectDragEndCallback: (mapObject) {
      showSnackBar(context, "End drag event");
      // Updates clusters position
      _clusterizedCollection.clusterPlacemarks(
        clusterRadius: _clusterRadius,
        minZoom: _clusterMinZoom,
      );
    },
  );

  late final _clusterTapListener = ClusterTapListenerImpl(
    onClusterTapCallback: (cluster) {
      showSnackBar(context, "Clicked on cluster with ${cluster.size} items");
      return true;
    },
  );

  late final _clusterListener = ClusterListenerImpl(
    onClusterAddedCallback: (cluster) {
      final placemarkTypes = cluster.placemarks
          .map((item) => _indexToPlacemarkType[item.userData])
          .whereType<PlacemarkType>()
          .toList();

      // Sets each cluster appearance using the custom view
      // that shows a cluster's pins
      cluster.appearance
        ..setView(
          ViewProvider(
            configurationFactory: (mediaQuery) => ViewConfiguration(
              physicalConstraints: BoxConstraints.tight(mediaQuery.size),
              logicalConstraints: BoxConstraints.tight(mediaQuery.size),
              devicePixelRatio: mediaQuery.devicePixelRatio,
            ),
            builder: () => ClusterWidget(placemarkTypes: placemarkTypes),
          ),
        )
        ..zIndex = 100.0;

      cluster.addClusterTapListener(_clusterTapListener);
    },
  );

  late final _geometryVisibilityVisitor = MapObjectVisitorImpl(
      onPlacemarkVisitedCallback: (_) {},
      onPolylineVisitedCallback: (polyline) {
        polyline.visible = _shouldShowGeometryOnMap;
      },
      onPolygonVisitedCallback: (polygon) {
        polygon.visible = _shouldShowGeometryOnMap;
      },
      onCircleVisitedCallback: (circle) {
        circle.visible = _shouldShowGeometryOnMap;
      },
      onCollectionVisitStartCallback: (_) => true,
      onCollectionVisitEndCallback: (_) {},
      onClusterizedCollectionVisitStartCallback: (_) => true,
      onClusterizedCollectionVisitEndCallback: (_) {});

  late final _singlePlacemarkTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (_, __) {
      showSnackBar(context, "Clicked the placemark with composite icon");
      return true;
    },
  );

  late final _animatedPlacemarkTapListener = MapObjectTapListenerImpl(
    onMapObjectTapped: (_, __) {
      showSnackBar(context, "Clicked the animated placemark");
      return true;
    },
  );

  late final mapkit.PolylineMapObject _polylineMapObject;
  late final mapkit.PolygonMapObject _polygonMapObject;

  mapkit.MapWindow? _mapWindow;
  bool _shouldShowGeometryOnMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(onMapCreated: _createMapObjects),
            Align(
              alignment: FractionalOffset.topLeft,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                      SimpleButton(
                        text: "Visibility",
                        onPressed: () {
                          showSnackBar(
                            context,
                            "${_mapObjectCollection.visible ? "Hide" : "Show"} all objects",
                          );
                          _mapObjectCollection.visible =
                              !_mapObjectCollection.visible;
                        },
                      ),
                      SimpleButton(
                        text: "Polyline",
                        onPressed: () {
                          final geometry = mapkit.Geometry.fromPolyline(
                            _polylineMapObject.geometry,
                          );
                          // Focus camera on polyline
                          _mapWindow?.map.let((map) {
                            map.moveWithAnimation(
                              map.cameraPositionForGeometry(geometry),
                              const mapkit.Animation(
                                mapkit.AnimationType.Smooth,
                                duration: 1.0,
                              ),
                            );
                          });
                        },
                      ),
                      SimpleButton(
                        text: "Polygon",
                        onPressed: () {
                          final geometry = mapkit.Geometry.fromPolygon(
                            _polygonMapObject.geometry,
                          );
                          // Focus camera on polygon
                          _mapWindow?.map.let((map) {
                            map.moveWithAnimation(
                              map.cameraPositionForGeometry(geometry),
                              const mapkit.Animation(
                                mapkit.AnimationType.Smooth,
                                duration: 1.0,
                              ),
                            );
                          });
                        },
                      ),
                      SimpleButton(
                        text:
                            "${_shouldShowGeometryOnMap ? "Off" : "On"} geometry",
                        onPressed: () {
                          // Turn off/on visibility
                          setState(() {
                            _shouldShowGeometryOnMap =
                                !_shouldShowGeometryOnMap;
                            _mapObjectCollection
                                .traverse(_geometryVisibilityVisitor);
                          });
                        },
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

  void _createMapObjects(mapkit.MapWindow mapWindow) {
    _mapWindow = mapWindow;

    mapWindow.addSizeChangedListener(_mapWindowSizeChangedListener);

    mapWindow.map.move(GeometryProvider.startPosition);

    // Add a nested map objects collection
    _mapObjectCollection = mapWindow.map.mapObjects.addCollection();

    _addPolygon(_mapObjectCollection);
    _addPolyline(_mapObjectCollection);
    _addCircle(_mapObjectCollection);

    // Add a clusterized collection
    _clusterizedCollection = _mapObjectCollection
        .addClusterizedPlacemarkCollection(_clusterListener);

    _addClusterizedPlacemarks(_clusterizedCollection);
    _addCompositePlacemark(_mapObjectCollection);
    _addAnimatedPlacemark(_mapObjectCollection);
  }

  void _addPolygon(mapkit.MapObjectCollection mapObjectCollection) {
    _polygonMapObject = mapObjectCollection.addPolygon(GeometryProvider.polygon)
      ..strokeWidth = 1.5
      ..strokeColor = Colors.orange
      ..fillColor = Colors.yellow;
  }

  void _addPolyline(mapkit.MapObjectCollection mapObjectCollection) {
    _polylineMapObject =
        mapObjectCollection.addPolylineWithGeometry(GeometryProvider.polyline)
          ..strokeWidth = 5.0
          ..setStrokeColor(Colors.green)
          ..outlineWidth = 1.0
          ..outlineColor = Colors.black
          ..addTapListener(_polylineTapListener);
  }

  void _addCircle(mapkit.MapObjectCollection mapObjectCollection) {
    mapObjectCollection.addCircle(GeometryProvider.circle)
      ..strokeWidth = 2.0
      ..strokeColor = Colors.blue
      ..fillColor = Colors.redAccent
      ..addTapListener(_circleTapListener);
  }

  void _addClusterizedPlacemarks(
    mapkit.ClusterizedPlacemarkCollection clusterizedCollection,
  ) {
    for (final (index, point) in GeometryProvider.clusterizedPoints.indexed) {
      final type = PlacemarkType.values.random();
      final imageProvider = _placemarkTypeToImageProvider[type];

      if (imageProvider != null) {
        clusterizedCollection.addPlacemark()
          ..geometry = point
          ..userData = index
          ..setIcon(imageProvider)
          ..setIconStyle(
            const mapkit.IconStyle(
              anchor: math.Point(0.5, 1.0),
              scale: 2.0,
            ),
          )
          // If we want to make placemarks draggable, we should call
          // clusterizedCollection.clusterPlacemarks on onMapObjectDragEnd
          ..draggable = true
          ..setDragListener(_pinDragListener)
          ..addTapListener(_placemarkTapListener);

        _indexToPlacemarkType[index] = type;
      }
    }

    clusterizedCollection.clusterPlacemarks(
      clusterRadius: _clusterRadius,
      minZoom: _clusterMinZoom,
    );
  }

  void _addCompositePlacemark(mapkit.MapObjectCollection mapObjectCollection) {
    final placemark = mapObjectCollection.addPlacemark()
      ..geometry = GeometryProvider.compositePointIcon
      ..addTapListener(_singlePlacemarkTapListener)
      // Set text near the placemark with the custom TextStyle
      ..setText("Special place")
      ..setTextStyle(
        const mapkit.TextStyle(
          size: 10.0,
          color: Colors.red,
          outlineColor: Colors.red,
          placement: mapkit.TextStylePlacement.Right,
          offset: 5.0,
        ),
      );

    placemark.useCompositeIcon()
      // Combine several icons in the single composite icon
      ..setIcon(
        image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/ic_dollar_pin.png"),
        ),
        const mapkit.IconStyle(anchor: math.Point(0.5, 1.0), scale: 2.0),
        name: "pin",
      )
      ..setIcon(
        image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/ic_circle.png"),
        ),
        const mapkit.IconStyle(
            anchor: math.Point(0.5, 0.5), flat: true, scale: 0.2),
        name: "point",
      );
  }

  void _addAnimatedPlacemark(mapkit.MapObjectCollection mapObjectCollection) {
    final animatedPlacemark = mapObjectCollection.addPlacemark()
      ..geometry = GeometryProvider.animatedImagePoint
      ..addTapListener(_animatedPlacemarkTapListener);

    animatedPlacemark.useAnimation()
      ..setIcon(
          image_provider.AnimatedImageProvider.fromAsset(
            "assets/animation.png",
          ),
          const mapkit.IconStyle(scale: 1.0))
      ..play();
  }

  void _updateFocusRect() {
    const horizontalMargin = 40.0;
    const verticalMargin = 60.0;

    _mapWindow?.let((it) {
      it.focusRect = mapkit.ScreenRect(
        const mapkit.ScreenPoint(
          x: horizontalMargin,
          y: verticalMargin,
        ),
        mapkit.ScreenPoint(
          x: it.width() - horizontalMargin,
          y: it.height() - verticalMargin,
        ),
      );
    });
  }
}
