import 'package:navikit_flutter_demo/data/simulation/listeners/location_simulator_listener_impl.dart';
import 'package:navikit_flutter_demo/domain/simulation/simulation_manager.dart';
import 'package:navikit_flutter_demo/domain/utils/speed_utils.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/mapkit_factory.dart';

final class SimulationManagerImpl implements SimulationManager {
  final _simulationActive = BehaviorSubject<bool>()..add(false);

  LocationSimulator? _locationSimulator;
  var _simulationSpeed = 75.0.toMetersPerSecond();

  late final _locationSimulatorListener = LocationSimulatorListenerImpl(
    stopSimulation,
  );

  @override
  Stream<bool> get simulationActive => _simulationActive;

  @override
  void startSimulation(DrivingRoute route) {
    _locationSimulator =
        mapkit.createLocationSimulator()
          ..subscribeForSimulatorEvents(_locationSimulatorListener);
    _locationSimulator?.let((it) {
      mapkit.setLocationManager(it);
      it.startSimulation(
        [SimulationSettings(route.geometry, LocationSettingsFactory.coarseSettings())]);
      it.speed = _simulationSpeed;
      _simulationActive.add(true);
    });
  }

  @override
  void stopSimulation() {
    _locationSimulator
        ?.unsubscribeFromSimulatorEvents(_locationSimulatorListener);
    _locationSimulator = null;
    mapkit.resetLocationManagerToDefault();
    _simulationActive.add(false);
  }

  @override
  void resume() {
    if (_simulationActive.valueOrNull == false) {
      _locationSimulator?.resume();
    }
  }

  @override
  void suspend() {
    if (_simulationActive.valueOrNull == true) {
      _locationSimulator?.suspend();
    }
  }

  @override
  void setSimulationSpeed(double speed) {
    _simulationSpeed = speed;
    _locationSimulator?.speed = _simulationSpeed;
  }

  @override
  void dispose() {
    _locationSimulator
        ?.unsubscribeFromSimulatorEvents(_locationSimulatorListener);
    _locationSimulator = null;
    _simulationActive.close();
  }
}
