import 'package:common/utils/extension_utils.dart';
import 'package:flutter/material.dart';

bool showSnackBar(BuildContext? context, String text) {
  final isShown = context?.let((it) {
    final snackBar = _getSnackBar(it, text);
    ScaffoldMessenger.of(it).showSnackBar(snackBar);
    return true;
  });
  return isShown ?? false;
}

SnackBar _getSnackBar(BuildContext context, String text) {
  return SnackBar(
    showCloseIcon: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    closeIconColor: Theme.of(context).colorScheme.secondary,
    duration: const Duration(milliseconds: 1000),
    behavior: SnackBarBehavior.floating,
    content: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge,
    ),
  );
}
