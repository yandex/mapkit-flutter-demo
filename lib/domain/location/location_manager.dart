import 'package:navikit_flutter_demo/domain/disposable_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

abstract interface class LocationManager implements DisposableManager {
  ValueStream<Location?> get location;

  void startListening();
}
