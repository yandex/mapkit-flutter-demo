import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/core/resources/dimensions.dart';
import 'package:navikit_flutter_demo/core/resources/strings/settings_strings.dart';
import 'package:navikit_flutter_demo/features/settings/settings_section_with_toggle.dart';

final class SettingsBottomsheet extends StatefulWidget {
  const SettingsBottomsheet({super.key});

  @override
  State<SettingsBottomsheet> createState() => SettingsBottomsheetState();
}

final class SettingsBottomsheetState extends State<SettingsBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: Dimensions.commonPadding,
          right: Dimensions.commonPadding,
        ),
        child: ListView(
          children: const [
            SettingsSectionWithToggle(title: SettingsStrings.fancyButton)
          ],
        ),
      ),
    );
  }
}
