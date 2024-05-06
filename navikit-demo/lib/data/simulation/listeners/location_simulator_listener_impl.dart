import 'package:yandex_maps_navikit/mapkit.dart';

final class LocationSimulatorListenerImpl implements LocationSimulatorListener {
  final void Function() _onSimulationFinished;

  const LocationSimulatorListenerImpl(this._onSimulationFinished);

  @override
  void onSimulationFinished() => _onSimulationFinished();
}
