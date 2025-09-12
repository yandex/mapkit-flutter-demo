import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/features/location_panel/models/location/location_model.dart';
import 'package:rxdart/rxdart.dart';

final class LocationModelProvider {
  final domain.LocationManager _locationManager;

  late final model = _locationManager.location.map((location) {
    return LocationModel(
      latitude: location?.position.latitude,
      longitude: location?.position.longitude,
      heading: location?.heading,
    );
  }).share();

  LocationModelProvider(this._locationManager);
}
