import 'dart:async';

import 'package:navikit_flutter_demo/domain/location/simple_guidance_listener.dart';
import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class LocationManagerGuidanceListener extends SimpleGuidanceListener {
  final Guidance _guidance;
  final StreamController<Location?> _location;

  var lastLocationTime = 0;
  static const locationUpdateTimeout = Duration(seconds: 1);

  LocationManagerGuidanceListener(this._location, this._guidance);

  @override
  void onLocationChanged() async {
    final timePassed = DateTime.now().millisecondsSinceEpoch - lastLocationTime;

    if (Duration(milliseconds: timePassed) >= locationUpdateTimeout) {
      lastLocationTime = DateTime.now().millisecondsSinceEpoch;
      _location.add(_guidance.location);
    }
  }
}
