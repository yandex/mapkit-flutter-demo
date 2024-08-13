import 'package:flutter/material.dart';

enum PlacemarkType {
  yellow,
  green,
  red,
}

class ClusterWidget extends StatefulWidget {
  final List<PlacemarkType> placemarkTypes;

  const ClusterWidget({
    super.key,
    required this.placemarkTypes,
  });

  @override
  State<StatefulWidget> createState() => ClusterWidgetState();
}

class ClusterWidgetState extends State<ClusterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(children: getPlacemarkWidgets().toList()),
    );
  }

  Iterable<Widget> getPlacemarkWidgets() sync* {
    for (final placemarkType in PlacemarkType.values) {
      final count = widget.placemarkTypes.count(placemarkType);

      if (count != 0) {
        final imageWidget = switch (placemarkType) {
          PlacemarkType.yellow => Image.asset(
              "assets/pin_yellow.png",
              width: 17.0,
              height: 17.0,
            ),
          PlacemarkType.green => Image.asset(
              "assets/pin_green.png",
              width: 17.0,
              height: 17.0,
            ),
          PlacemarkType.red => Image.asset(
              "assets/pin_red.png",
              width: 17.0,
              height: 17.0,
            ),
        };

        yield Row(
          children: [
            imageWidget,
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        );
      }
    }
  }
}

extension CountExtension<T> on Iterable<T> {
  int count(T item) {
    var count = 0;
    for (final element in this) {
      if (element == item) {
        count++;
      }
    }
    return count;
  }
}
