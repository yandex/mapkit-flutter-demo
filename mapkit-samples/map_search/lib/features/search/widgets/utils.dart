import 'package:collection/collection.dart';
import 'package:flutter/material.dart' as material;
import 'package:yandex_maps_mapkit/mapkit.dart';

extension VisibleRegionToBoundingBox on VisibleRegion {
  BoundingBox toBoundingBox() => BoundingBox(bottomLeft, topRight);
}

extension ToTextSpans on SpannableString {
  List<material.TextSpan> toTextSpans({
    required material.Color defaultColor,
    required material.Color spanColor,
  }) {
    var spannableTexts = <material.TextSpan>[];

    if (spans.isNotEmpty) {
      spannableTexts.add(
        material.TextSpan(
          text: text.substring(0, spans.first.begin),
          style: material.TextStyle(
            color: defaultColor,
          ),
        ),
      );

      spans.forEachIndexed((index, span) {
        spannableTexts.add(
          material.TextSpan(
            text: text.substring(span.begin, span.end),
            style: material.TextStyle(
              color: spanColor,
            ),
          ),
        );
      });

      if (spans.last.end != text.length) {
        spannableTexts.add(
          material.TextSpan(
            text: text.substring(spans.last.end),
            style: material.TextStyle(
              color: defaultColor,
            ),
          ),
        );
      }
    } else {
      spannableTexts.add(
        material.TextSpan(
          text: text,
          style: material.TextStyle(
            color: defaultColor,
          ),
        ),
      );
    }
    return spannableTexts;
  }
}
