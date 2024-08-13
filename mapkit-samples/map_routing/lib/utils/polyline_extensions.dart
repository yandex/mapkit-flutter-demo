import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

extension StyleMainRoute on PolylineMapObject {
  void applyMainRouteStyle() {
    this
      ..zIndex = 10.0
      ..setStrokeColor(Colors.red)
      ..strokeWidth = 5.0
      ..outlineColor = Colors.black
      ..outlineWidth = 3.0;
  }
}

extension StyleAlternativeRoute on PolylineMapObject {
  void applyAlternativeRouteStyle() {
    this
      ..zIndex = 5.0
      ..setStrokeColor(Colors.lightBlue)
      ..strokeWidth = 4.0
      ..outlineColor = Colors.black
      ..outlineWidth = 2.0;
  }
}
