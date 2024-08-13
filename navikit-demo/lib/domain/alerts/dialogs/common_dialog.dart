import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialog_provider.dart';

final class CommonDialog extends StatelessWidget {
  final String descriptionText;
  final ButtonTextsWithActions buttons;

  const CommonDialog({
    super.key,
    required this.descriptionText,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    final actionButtons = buttons.map((button) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          button.$2();
        },
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        child: Text(button.$1),
      );
    }).toList();

    return AlertDialog(
      content: Text(descriptionText),
      contentTextStyle: Theme.of(context).textTheme.labelLarge,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: actionButtons,
    );
  }
}
