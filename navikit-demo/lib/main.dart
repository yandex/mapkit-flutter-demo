import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:navikit_flutter_demo/core/resources/theme.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_suspender_manager.dart';
import 'package:navikit_flutter_demo/domain/permissions/permission_manager.dart';
import 'package:navikit_flutter_demo/features/map_screen/ui/maps/flutter_map_widget.dart';
import 'package:navikit_flutter_demo/features/settings/settings_bottomsheet.dart';
import 'package:yandex_maps_navikit/init.dart' as init;

import 'dependencies/application_deps/application_deps_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApplicationDeps();
  await dotenv.load(fileName: ".env");
  await init.initMapkit(apiKey: dotenv.env["API_KEY"]!);

  runApp(
    MaterialApp(
      theme: NavikitFlutterTheme.lightTheme,
      darkTheme: NavikitFlutterTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const NavikitFlutterApp(),
    ),
  );
}

class NavikitFlutterApp extends StatefulWidget {
  const NavikitFlutterApp({super.key});

  @override
  State<NavikitFlutterApp> createState() => _NavikitFlutterAppState();
}

class _NavikitFlutterAppState extends State<NavikitFlutterApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _requestPermissionsIfNeeded();
      },
      onShow: () {
        navigationSuspenderManager.registerClient(NavigationClient.application);
      },
      onHide: () {
        _serializeNavigationIfNeeded();
        navigationSuspenderManager.removeClient(NavigationClient.application);
      },
    );

    navigationSuspenderManager.registerClient(NavigationClient.application);
    _requestPermissionsIfNeeded();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    disposeApplicationDeps();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Center(
        child: FlutterMapWidget(
          showSettingsBottomsheet: _showSettingsBottomsheet,
        ),
      ),
    );
  }

  void _showSettingsBottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => const SettingsBottomsheet(),
    );
  }

  void _requestPermissionsIfNeeded() {
    final permissions = [PermissionType.accessLocation];
    permissionManager.tryToRequest(permissions);
    permissionManager.showRequestDialog(permissions);
  }

  void _serializeNavigationIfNeeded() {
    if (settingsManager.restoreGuidanceState.value &&
        navigationManager.isGuidanceActive) {
      navigationHolder.serialize();
    }
  }
}
