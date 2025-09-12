import 'package:flutter/foundation.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

final class LocationSimulatorListenerImpl implements LocationSimulatorListener {
  final VoidCallback _onSimulationFinished;

  const LocationSimulatorListenerImpl(this._onSimulationFinished);

  @override
  void onSimulationFinished() => _onSimulationFinished();
}
