import 'package:flutter/material.dart';

final class RegionItemWidget extends StatelessWidget {
  final String regionName;
  final String cities;
  final VoidCallback? onTap;

  const RegionItemWidget({
    super.key,
    required this.regionName,
    required this.cities,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regionName,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          Text(
            cities,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 10.0)
        ],
      ),
    );
  }
}
