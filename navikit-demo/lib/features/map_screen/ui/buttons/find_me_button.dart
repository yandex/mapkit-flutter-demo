import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/model/guidance_model.dart';

import 'map_control_button.dart';

final class FindMeButton extends StatelessWidget {
  final Stream<bool?> isGuidanceActive;
  final VoidCallback defaultAction;
  final VoidCallback actionInGuidanceMode;

  FindMeButton({
    super.key,
    required Stream<GuidanceModel> guidanceModel,
    required this.defaultAction,
    required this.actionInGuidanceMode,
  }) : isGuidanceActive = guidanceModel.map((it) => it.isGuidanceActive);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: isGuidanceActive,
      builder: (context, isGuidanceActive) {
        return MapControlButton(
          icon: Icons.my_location_outlined,
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          onPressed: isGuidanceActive.data == true
              ? actionInGuidanceMode
              : defaultAction,
        );
      },
    );
  }
}
