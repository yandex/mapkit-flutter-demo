import 'package:flutter/foundation.dart';

typedef ButtonTextsWithActions = List<(String, VoidCallback)>;

final class DialogsFactory {
  final void Function(String, ButtonTextsWithActions) _showDialog;

  const DialogsFactory(this._showDialog);

  void showPermissionRequestDialog({
    required String description,
    required VoidCallback primaryAction,
  }) {
    final buttons = [
      ("OK", primaryAction),
      ("Dismiss", () {}),
    ];
    _showDialog(description, buttons);
  }
}
