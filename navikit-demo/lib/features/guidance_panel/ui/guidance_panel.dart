import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/core/resources/dimensions.dart';
import 'package:navikit_flutter_demo/core/resources/strings/guidance_strings.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/model/guidance_model.dart';

final class GuidancePanel extends StatelessWidget {
  final Stream<GuidanceModel> guidanceModel;
  final VoidCallback closeGuidanceAction;

  const GuidancePanel({
    super.key,
    required this.guidanceModel,
    required this.closeGuidanceAction,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: guidanceModel,
      builder: (context, snapshot) {
        if (snapshot.data?.isGuidanceActive == true) {
          final distanceLeft = snapshot.data?.distanceLeft?.text;
          final timeWithTraffic = snapshot.data?.timeWithTraffic?.text;
          final roadFlags = snapshot.data?.roadFlags;
          final roadName = snapshot.data?.roadName;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.commonBorderRadius),
                topRight: Radius.circular(Dimensions.commonBorderRadius),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.commonPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${GuidanceStrings.distance} $distanceLeft",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: Dimensions.commonSpacing),
                            Text(
                              "${GuidanceStrings.time} $timeWithTraffic",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: Dimensions.commonSpacing),
                            Text(
                              roadFlags?.isNotEmpty == true
                                  ? "${GuidanceStrings.flags} $roadFlags"
                                  : "",
                              style: Theme.of(context).textTheme.labelSmall,
                            )
                          ],
                        ),
                        Text(
                          "${GuidanceStrings.street} $roadName",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: closeGuidanceAction,
                    color: Theme.of(context).colorScheme.secondary,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    minWidth: 0,
                    height: 20.0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Icon(
                      Icons.close,
                      size: 20.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
