import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/core/resources/dimensions.dart';
import 'package:navikit_flutter_demo/core/resources/strings/route_strings.dart';
import 'package:navikit_flutter_demo/features/route_variants_panel/model/route_variants_screen_model.dart';

final class RouteVariantsPanel extends StatelessWidget {
  final Stream<RouteVariantsScreenModel> routeVariantsScreenModel;
  final VoidCallback? onGoClicked;
  final VoidCallback? onCancelClicked;

  const RouteVariantsPanel({
    super.key,
    required this.routeVariantsScreenModel,
    required this.onGoClicked,
    required this.onCancelClicked,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: routeVariantsScreenModel,
      builder: (context, snapshot) {
        if (snapshot.data?.isRouteVariantsVisible == true) {
          return DecoratedBox(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancelClicked,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: Dimensions.outlinedButtonBorderWidth,
                        ),
                      ),
                      child: Text(
                        RouteStrings.cancelRouteText,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.commonSpacing),
                  Expanded(
                    child: FilledButton(
                      onPressed: onGoClicked,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        RouteStrings.startRouteText,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.white),
                      ),
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
