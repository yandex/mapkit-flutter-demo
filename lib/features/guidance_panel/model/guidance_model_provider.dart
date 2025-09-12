import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/navigation/navigation_manager.dart';
import 'package:navikit_flutter_demo/domain/simulation/simulation_manager.dart';
import 'package:navikit_flutter_demo/domain/utils/route_utils.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/model/guidance_model.dart';
import 'package:rxdart/rxdart.dart';

final class GuidanceModelProvider {
  final domain.LocationManager _locationManager;
  final NavigationManager _navigationManager;
  final SimulationManager _simulationManager;

  late final model = Rx.combineLatest6(
    _navigationManager.guidanceActive,
    _simulationManager.simulationActive,
    _navigationManager.currentRoute,
    _navigationManager.roadName,
    _navigationManager.roadFlags,
    _locationManager.location,
    (isGuidanceActive, isSimulationActive, currentRoute, roadName, roadFlags,
        location) {
      return GuidanceModel(
        isGuidanceActive: isGuidanceActive,
        isSimulationActive: isSimulationActive,
        roadName: roadName,
        roadFlags: roadFlags,
        location: location,
        distanceLeft: currentRoute?.distanceLeft(),
        timeWithTraffic: currentRoute?.timeWithTraffic(),
      );
    },
  ).share();

  GuidanceModelProvider(
      this._locationManager, this._navigationManager, this._simulationManager);
}
