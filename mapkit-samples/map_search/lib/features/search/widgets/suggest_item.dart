import 'package:flutter/material.dart';
import 'package:map_search/features/search/widgets/utils.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class SuggestItemWidget extends StatelessWidget {
  final SpannableString title;
  final SpannableString? subtitle;
  final VoidCallback? onTap;

  const SuggestItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "",
              style: Theme.of(context).textTheme.labelMedium,
              children: title.toTextSpans(
                defaultColor: Theme.of(context).colorScheme.onPrimary,
                spanColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          RichText(
            text: TextSpan(
              text: "",
              style: Theme.of(context).textTheme.labelSmall,
              children: subtitle?.toTextSpans(
                defaultColor: Theme.of(context).colorScheme.onPrimary,
                spanColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
