import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:yandex_maps_navikit/directions.dart';

abstract interface class SimulationManager implements DisposableManager {
  Stream<bool> get simulationActive;

  void startSimulation(DrivingRoute route);
  void stopSimulation();

  void resume();
  void suspend();

  void setSimulationSpeed(double speed);
}
