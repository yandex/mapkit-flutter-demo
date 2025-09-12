import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/core/resources/dimensions.dart';
import 'package:navikit_flutter_demo/core/resources/strings/location_strings.dart';
import 'package:navikit_flutter_demo/features/location_panel/models/camera/camera_model.dart';
import 'package:navikit_flutter_demo/features/location_panel/models/location/location_model.dart';

final class LocationPanel extends StatefulWidget {
  final Color backgroundColor;
  final Stream<LocationModel> locationModel;
  final Stream<CameraModel> cameraModel;

  const LocationPanel({
    super.key,
    required this.backgroundColor,
    required this.locationModel,
    required this.cameraModel,
  });

  @override
  State<StatefulWidget> createState() => LocationPanelState();
}

final class LocationPanelState extends State<LocationPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(Dimensions.commonBorderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.panelPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocationStrings.location,
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            StreamBuilder(
              stream: widget.locationModel,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${LocationStrings.latitude} ${snapshot.data?.latitude}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${LocationStrings.longitude} ${snapshot.data?.longitude}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${LocationStrings.heading} ${snapshot.data?.heading}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: Dimensions.panelPadding),
            Text(
              LocationStrings.camera,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            StreamBuilder(
              stream: widget.cameraModel,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${LocationStrings.azimuth} ${snapshot.data?.azimuth}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
