import 'package:flutter/material.dart';

final class RegionSectionWidget extends StatelessWidget {
  final String sectionName;

  const RegionSectionWidget({super.key, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionName,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Divider(
          height: 8.0,
          thickness: 1.0,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        const SizedBox(height: 10.0)
      ],
    );
  }
}
