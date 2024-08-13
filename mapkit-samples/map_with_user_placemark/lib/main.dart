import 'dart:math' as math;

import 'package:common/map/flutter_map_widget.dart';
import 'package:common/resources/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:map_with_user_placemark/camera/camera_manager.dart';
import 'package:map_with_user_placemark/dialogs/dialogs_factory.dart';
import 'package:map_with_user_placemark/widgets/map_control_button.dart';
import 'package:map_with_user_placemark/permissions/permission_manager.dart';
import 'package:yandex_maps_mapkit/image.dart' as image_provider;
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';

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
    implements UserLocationObjectListener {
  late final _dialogsFactory = DialogsFactory(_showDialog);
  late final _permissionManager = PermissionManager(_dialogsFactory);
  late final _locationManager = mapkit.createLocationManager();

  late final CameraManager _cameraManager;
  late final UserLocationLayer _userLocationLayer;
  late final AppLifecycleListener _lifecycleListener;

  late final MapWindow _mapWindow;

  late final arrowIconImageProvider =
      image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/user_arrow.png"));
  late final iconImageProvider = image_provider.ImageProvider.fromImageProvider(
      const AssetImage("assets/icon.png"));
  late final pinIconImageProvider =
      image_provider.ImageProvider.fromImageProvider(
          const AssetImage("assets/icon_pin.png"));

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _requestPermissionsIfNeeded();
      },
    );

    _requestPermissionsIfNeeded();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
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
              onMapCreated: (mapWindow) {
                _mapWindow = mapWindow;

                _cameraManager = CameraManager(mapWindow, _locationManager)
                  ..start();

                _userLocationLayer = mapkit.createUserLocationLayer(mapWindow)
                  ..headingEnabled = true
                  ..setVisible(true)
                  ..setObjectListener(this);
              },
              onMapDispose: () {
                _cameraManager.dispose();
              },
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: MapControlButton(
                    icon: Icons.my_location_outlined,
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    onPressed: () {
                      _cameraManager.moveCameraToUserLocation();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onObjectAdded(UserLocationView userLocationView) {
    _userLocationLayer.setAnchor(
      math.Point(_mapWindow.width() * 0.5, _mapWindow.height() * 0.5),
      math.Point(_mapWindow.width() * 0.5, _mapWindow.height() * 0.5),
    );

    userLocationView.arrow.setIcon(arrowIconImageProvider);

    final pinIcon = userLocationView.pin.useCompositeIcon();

    pinIcon.setIcon(
      iconImageProvider,
      const IconStyle(
        anchor: math.Point(0.0, 0.0),
        rotationType: RotationType.Rotate,
        zIndex: 0.0,
        scale: 0.75,
      ),
      name: "icon",
    );

    pinIcon.setIcon(
      pinIconImageProvider,
      const IconStyle(
        anchor: math.Point(0.5, 0.5),
        rotationType: RotationType.Rotate,
        zIndex: 1.0,
        scale: 1.0,
      ),
      name: "pin",
    );

    userLocationView.accuracyCircle.fillColor = Colors.blue.withAlpha(100);
  }

  @override
  void onObjectRemoved(UserLocationView view) {}

  @override
  void onObjectUpdated(UserLocationView view, ObjectEvent event) {}

  void _showDialog(
    String descriptionText,
    ButtonTextsWithActions buttonTextsWithActions,
  ) {
    final actionButtons = buttonTextsWithActions.map((button) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          button.$2();
        },
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        child: Text(button.$1),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(descriptionText),
          contentTextStyle: Theme.of(context).textTheme.labelLarge,
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: actionButtons,
        );
      },
    );
  }

  void _requestPermissionsIfNeeded() {
    final permissions = [PermissionType.accessLocation];
    _permissionManager.tryToRequest(permissions);
    _permissionManager.showRequestDialog(permissions);
  }
}
