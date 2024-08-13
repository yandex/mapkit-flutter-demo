import 'package:flutter/material.dart';

final class SettingsSectionWithToggle extends StatefulWidget {
  final String title;
  final void Function(bool value)? onChanged;

  const SettingsSectionWithToggle({
    super.key,
    required this.title,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => SettingsSectionWithToggleState();
}

final class SettingsSectionWithToggleState
    extends State<SettingsSectionWithToggle> {
  bool isEnabled = false;

  late String title;
  late void Function(bool value)? onChanged;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    onChanged = widget.onChanged;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _updateState,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Switch(
            value: isEnabled,
            thumbColor: MaterialStateProperty.resolveWith(_updateThumbColor),
            trackColor: MaterialStateProperty.resolveWith(_updateTrackColor),
            trackOutlineColor:
                MaterialStateProperty.resolveWith(_updateOutlineColor),
            onChanged: (bool _) => _updateState(),
          ),
        ],
      ),
    );
  }

  void _updateState() {
    setState(() {
      isEnabled = !isEnabled;
      onChanged?.call(isEnabled);
    });
  }

  Color? _updateThumbColor(Set<MaterialState> states) {
    if (!states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.onTertiary;
    }
    return Colors.white;
  }

  Color? _updateTrackColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    }
    return null;
  }

  Color? _updateOutlineColor(Set<MaterialState> states) {
    if (!states.contains(MaterialState.selected)) {
      return Theme.of(context).colorScheme.onTertiary;
    }
    return null;
  }
}
