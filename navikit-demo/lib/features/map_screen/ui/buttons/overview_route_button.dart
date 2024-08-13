import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/features/guidance_panel/model/guidance_model.dart';
import 'package:navikit_flutter_demo/features/map_screen/ui/buttons/map_control_button.dart';

final class OverviewRouteButton extends StatelessWidget {
  final Stream<bool?> isGuidanceActive;
  final VoidCallback? onPressed;

  OverviewRouteButton({
    super.key,
    required Stream<GuidanceModel> guidanceModel,
    this.onPressed,
  }) : isGuidanceActive = guidanceModel.map((it) => it.isGuidanceActive);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: isGuidanceActive,
      builder: (context, isGuidanceActive) {
        if (isGuidanceActive.data == true) {
          return MapControlButton(
            icon: Icons.route_outlined,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onPressed: onPressed,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
