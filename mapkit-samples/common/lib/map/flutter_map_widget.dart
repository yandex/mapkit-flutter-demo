import 'package:common/utils/extension_utils.dart';
import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/mapkit_factory.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';

final class FlutterMapWidget extends StatefulWidget {
  final void Function(MapWindow) onMapCreated;
  final VoidCallback? onMapDispose;

  const FlutterMapWidget({
    super.key,
    required this.onMapCreated,
    this.onMapDispose,
  });

  @override
  State<FlutterMapWidget> createState() => FlutterMapWidgetState();
}

final class FlutterMapWidgetState extends State<FlutterMapWidget> {
  late final AppLifecycleListener _lifecycleListener;

  MapWindow? _mapWindow;
  bool _isMapkitActive = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: YandexMap(
        onMapCreated: _onMapCreated,
        platformViewType: PlatformViewType.Hybrid,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startMapkit();

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
    _stopMapkit();
    _lifecycleListener.dispose();
    widget.onMapDispose?.call();
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
    window.let((it) {
      widget.onMapCreated(window);
      _mapWindow = it;

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
    _mapWindow?.map.nightModeEnabled =
        Theme.of(context).brightness == Brightness.dark;
  }
}
