import 'package:collection/collection.dart';
import 'package:common/buttons/simple_button.dart';
import 'package:common/listeners/map_input_listener.dart';
import 'package:common/map/flutter_map_widget.dart';
import 'package:common/resources/theme.dart';
import 'package:common/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:map_routing/data/geometry_provider.dart';
import 'package:map_routing/data/routing_type.dart';
import 'package:map_routing/utils/polyline_extensions.dart';
import 'package:yandex_maps_mapkit/directions.dart';
import 'package:yandex_maps_mapkit/image.dart' as image_provider;
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/runtime.dart';
import 'package:yandex_maps_mapkit/transport.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /**
   * Replace "your_api_key" with a valid developer key.
   */
  await init.initMapkit(apiKey: "your_api_key");

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
  MapWindow? _mapWindow;

  var _routePoints = <Point>[];
  var _drivingRoutes = <DrivingRoute>[];
  var _pedestrianRoutes = <MasstransitRoute>[];
  var _publicTransportRoutes = <MasstransitRoute>[];
  var _currentRoutingType = RoutingType.driving;

  List<Point> get routePoints => _routePoints;
  List<DrivingRoute> get drivingRoutes => _drivingRoutes;
  List<MasstransitRoute> get pedestrianRoutes => _pedestrianRoutes;
  List<MasstransitRoute> get publicTransportRoutes => _publicTransportRoutes;
  RoutingType get currentRoutingType => _currentRoutingType;

  set routePoints(List<Point> newValue) {
    _routePoints = newValue;
    _onRouteParametersUpdated();
  }

  set drivingRoutes(List<DrivingRoute> newValue) {
    _drivingRoutes = newValue;
    _onDrivingRoutesUpdated();
  }

  set pedestrianRoutes(List<MasstransitRoute> newValue) {
    _pedestrianRoutes = newValue;
    _onPedestrianRoutesUpdated();
  }

  set publicTransportRoutes(List<MasstransitRoute> newValue) {
    _publicTransportRoutes = newValue;
    _onPublicTransportRoutesUpdated();
  }

  set currentRoutingType(RoutingType newValue) {
    _currentRoutingType = newValue;
    _onRouteParametersUpdated();
  }

  DrivingSession? _drivingSession;
  late final DrivingRouter _drivingRouter;

  MasstransitSession? _pedestrianSession;
  late final PedestrianRouter _pedestrianRouter;

  MasstransitSession? _publicTransportSession;
  late final MasstransitRouter _publicTransportRouter;

  late final MapObjectCollection _placemarksCollection;
  late final MapObjectCollection _routesCollection;

  late final pointImageProvider =
      image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/ic_point.png"));

  late final finishPointImageProvider =
      image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/ic_finish_point.png"));

  late final _inputListener = MapInputListenerImpl(
    onMapTapCallback: (_, __) {},
    onMapLongTapCallback: (map, point) {
      routePoints = [...routePoints, point];
      if (routePoints.length == 1) {
        showSnackBar(context, "Added first route point");
      }
    },
  );

  late final _drivingRouteListener = DrivingSessionRouteListener(
    onDrivingRoutes: (newRoutes) {
      if (newRoutes.isEmpty) {
        showSnackBar(context, "Can't build a route");
      }
      drivingRoutes = newRoutes;
    },
    onDrivingRoutesError: (Error error) {
      switch (error) {
        case final NetworkError _:
          showSnackBar(
            context,
            "Driving routes request error due network issue",
          );
        default:
          showSnackBar(context, "Driving routes request unknown error");
      }
    },
  );

  late final _pedestrianRouteListener = RouteHandler(
    onMasstransitRoutes: (newRoutes) {
      if (newRoutes.isEmpty) {
        showSnackBar(context, "Can't build a route");
      }
      pedestrianRoutes = newRoutes;
    },
    onMasstransitRoutesError: (error) {
      switch (error) {
        case final NetworkError _:
          showSnackBar(
            context,
            "Pedestrian routes request error due network issue",
          );
        default:
          showSnackBar(context, "Pedestrian routes request unknown error");
      }
    },
  );

  late final _publicTransportRouteListener = RouteHandler(
    onMasstransitRoutes: (newRoutes) {
      if (newRoutes.isEmpty) {
        showSnackBar(context, "Can't build a route");
      }
      publicTransportRoutes = newRoutes;
    },
    onMasstransitRoutesError: (error) {
      switch (error) {
        case final NetworkError _:
          showSnackBar(
            context,
            "Public transport routes request error due network issue",
          );
        default:
          showSnackBar(
            context,
            "Public transport routes request unknown error",
          );
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMapWidget(
              onMapCreated: _createMapObjects,
              onMapDispose: () {
                _mapWindow?.map.removeInputListener(_inputListener);
              },
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 10.0,
                    children: [
                      SimpleButton(
                        text: "Clear routes",
                        onPressed: () {
                          routePoints = [];
                          showSnackBar(context, "Cleared all route points");
                        },
                      ),
                      SimpleButton(
                        text:
                            "Current route type: ${currentRoutingType.purpose}",
                        onPressed: () {
                          setState(() {
                            switch (currentRoutingType) {
                              case RoutingType.driving:
                                currentRoutingType = RoutingType.pedestrian;
                              case RoutingType.pedestrian:
                                currentRoutingType =
                                    RoutingType.publicTransport;
                              case RoutingType.publicTransport:
                                currentRoutingType = RoutingType.driving;
                            }
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

  void _createMapObjects(MapWindow mapWindow) {
    _mapWindow = mapWindow;

    mapWindow.map.move(GeometryProvider.startPosition);
    mapWindow.map.addInputListener(_inputListener);

    _placemarksCollection = mapWindow.map.mapObjects.addCollection();
    _routesCollection = mapWindow.map.mapObjects.addCollection();

    _drivingRouter = DirectionsFactory.instance
        .createDrivingRouter(DrivingRouterType.Combined);
    _pedestrianRouter = TransportFactory.instance.createPedestrianRouter();
    _publicTransportRouter =
        TransportFactory.instance.createMasstransitRouter();

    routePoints = GeometryProvider.defaultPoints;
  }

  void _onRouteParametersUpdated() {
    _placemarksCollection.clear();

    if (routePoints.isEmpty) {
      switch (currentRoutingType) {
        case RoutingType.driving:
          _drivingSession?.cancel();
          drivingRoutes = [];
        case RoutingType.pedestrian:
          _pedestrianSession?.cancel();
          pedestrianRoutes = [];
        case RoutingType.publicTransport:
          _publicTransportSession?.cancel();
          publicTransportRoutes = [];
      }
      return;
    }

    routePoints.forEachIndexed((index, point) {
      final placemark = _placemarksCollection.addPlacemark()..geometry = point;

      if (index != routePoints.length - 1) {
        placemark
          ..setIcon(pointImageProvider)
          ..setIconStyle(const IconStyle(scale: 2.5, zIndex: 20.0));
      } else {
        placemark
          ..setIcon(finishPointImageProvider)
          ..setIconStyle(const IconStyle(scale: 1.5, zIndex: 20.0));
      }
    });

    if (routePoints.length < 2) {
      return;
    }

    final requestPoints = [
      RequestPoint(routePoints.first, RequestPointType.Waypoint, null, null, null),
      ...(routePoints.sublist(1, routePoints.length - 1).map(
          (it) => RequestPoint(it, RequestPointType.Viapoint, null, null, null))),
      RequestPoint(routePoints.last, RequestPointType.Waypoint, null, null, null)
    ];

    switch (currentRoutingType) {
      case RoutingType.driving:
        _requestDrivingRoutes(requestPoints);
      case RoutingType.pedestrian:
        _requestPedestrianRoutes(requestPoints);
      case RoutingType.publicTransport:
        _requestPublicTransportRoutes(requestPoints);
    }
  }

  void _onDrivingRoutesUpdated() {
    _routesCollection.clear();
    if (drivingRoutes.isEmpty) {
      return;
    }

    drivingRoutes.forEachIndexed((index, route) {
      _createPolylineWithStyle(index, route.geometry);
    });
  }

  void _onPedestrianRoutesUpdated() {
    _routesCollection.clear();
    if (pedestrianRoutes.isEmpty) {
      return;
    }

    pedestrianRoutes.forEachIndexed((index, route) {
      _createPolylineWithStyle(index, route.geometry);
    });
  }

  void _onPublicTransportRoutesUpdated() {
    _routesCollection.clear();
    if (publicTransportRoutes.isEmpty) {
      return;
    }

    publicTransportRoutes.forEachIndexed((index, route) {
      _createPolylineWithStyle(index, route.geometry);
    });
  }

  void _createPolylineWithStyle(int routeIndex, Polyline routeGeometry) {
    final polyline = _routesCollection.addPolylineWithGeometry(routeGeometry);
    routeIndex == 0
        ? polyline.applyMainRouteStyle()
        : polyline.applyAlternativeRouteStyle();
  }

  void _requestDrivingRoutes(List<RequestPoint> points) {
    const drivingOptions = DrivingOptions(routesCount: 3);
    const vehicleOptions = DrivingVehicleOptions();

    _drivingSession = _drivingRouter.requestRoutes(
      drivingOptions,
      vehicleOptions,
      _drivingRouteListener,
      points: points,
    );
  }

  void _requestPedestrianRoutes(List<RequestPoint> points) {
    const timeOptions = TimeOptions();
    const routeOptions = RouteOptions(FitnessOptions(avoidSteep: false));

    _pedestrianSession = _pedestrianRouter.requestRoutes(
      timeOptions,
      routeOptions,
      _pedestrianRouteListener,
      points: points,
    );
  }

  void _requestPublicTransportRoutes(List<RequestPoint> points) {
    const timeOptions = TimeOptions();
    const transitOptions = TransitOptions(timeOptions);
    const routeOptions = RouteOptions(FitnessOptions(avoidSteep: false));

    _publicTransportSession = _publicTransportRouter.requestRoutes(
      transitOptions,
      routeOptions,
      _publicTransportRouteListener,
      points: points,
    );
  }
}
