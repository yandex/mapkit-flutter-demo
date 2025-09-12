import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/domain/alerts/snackbars/snackbar_factory.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';

final class SnackBarFactoryImpl implements SnackBarFactory {
  final GlobalKey _globalKey;

  SnackBarFactoryImpl(this._globalKey);

  BuildContext? get _context => _globalKey.currentContext;

  @override
  bool showSnackBar(String text) {
    return _context?.let((context) {
          final snackBar = getSnackBar(context, text);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return true;
        }) ??
        false;
  }

  SnackBar getSnackBar(BuildContext context, String text) {
    return SnackBar(
      showCloseIcon: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      closeIconColor: Theme.of(context).colorScheme.secondary,
      content: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
