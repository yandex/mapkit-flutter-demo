import 'package:flutter/material.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/common_dialog.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialog_provider.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';

final class DialogProviderImpl implements DialogProvider {
  final GlobalKey _globalKey;

  DialogProviderImpl(this._globalKey);

  BuildContext? get _context => _globalKey.currentContext;

  @override
  bool showCommonDialog(String description, ButtonTextsWithActions buttons) {
    return _context?.let((it) {
          showDialog(
            context: it,
            builder: (BuildContext context) => CommonDialog(
              descriptionText: description,
              buttons: buttons,
            ),
          );
          return true;
        }) ??
        false;
  }
}
