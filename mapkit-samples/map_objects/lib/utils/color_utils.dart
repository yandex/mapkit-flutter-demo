import 'package:common/utils/extension_utils.dart';
import 'package:flutter/material.dart';

final class ColorUtils {
  static var _colorIndex = 0;
  static final _colors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
  ];

  static Color get polylineColor {
    return _colors[_colorIndex].also((it) {
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }
}
