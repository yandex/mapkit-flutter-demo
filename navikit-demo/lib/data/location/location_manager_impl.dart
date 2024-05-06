import 'package:navikit_flutter_demo/data/location/location_manager_guidance_listener.dart';
import 'package:navikit_flutter_demo/domain/location/location_manager.dart'
    as domain;
import 'package:navikit_flutter_demo/domain/location/simple_guidance_listener.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class LocationManagerImpl implements domain.LocationManager {
  final Navigation _navigation;
  final _location = BehaviorSubject<Location?>();

  late final SimpleGuidanceListener _guidanceListener =
      LocationManagerGuidanceListener(_location, _navigation.guidance);

  LocationManagerImpl(this._navigation);

  @override
  ValueStream<Location?> get location => _location;

  @override
  void startListening() {
    _navigation.guidance.addListener(_guidanceListener);
  }

  @override
  void dispose() {
    _navigation.guidance.removeListener(_guidanceListener);
  }
}
