import 'package:flutter/foundation.dart';
import 'package:navikit_flutter_demo/core/resources/strings/alert_strings.dart';
import 'package:navikit_flutter_demo/core/resources/strings/guidance_strings.dart';
import 'package:navikit_flutter_demo/core/resources/strings/route_strings.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialog_provider.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialogs_factory.dart';

final class DialogsFactoryImpl implements DialogsFactory {
  final DialogProvider _dialogProvider;

  const DialogsFactoryImpl(this._dialogProvider);

  @override
  void showPermissionRequestDialog({
    required String description,
    required VoidCallback primaryAction,
  }) {
    final buttons = [
      (AlertStrings.dialogAcceptButtonText, primaryAction),
      (AlertStrings.dialogCancelButtonText, () {}),
    ];
    _dialogProvider.showCommonDialog(description, buttons);
  }

  @override
  void showRequestToPointDialog({
    required VoidCallback primaryAction,
  }) {
    final buttons = [
      (AlertStrings.dialogAcceptButtonText, primaryAction),
      (AlertStrings.dialogCancelButtonText, () {}),
    ];
    _dialogProvider.showCommonDialog(
      RouteStrings.buildRouteDialogText,
      buttons,
    );
  }

  @override
  void showRequestPointDialog({
    required VoidCallback onToClicked,
    required VoidCallback onViaClicked,
    required VoidCallback onFromClicked,
  }) {
    final buttons = [
      (RouteStrings.addToPointText, onToClicked),
      (RouteStrings.addViaPointText, onViaClicked),
      (RouteStrings.addFromPointText, onFromClicked),
    ];
    _dialogProvider.showCommonDialog(
      RouteStrings.addPointToRouteText,
      buttons,
    );
  }

  @override
  void showCancelGuidanceDialog({
    required VoidCallback primaryAction,
  }) {
    final buttons = [
      (AlertStrings.dialogYesButtonText, primaryAction),
      (AlertStrings.dialogNoButtonText, () {})
    ];
    _dialogProvider.showCommonDialog(
      GuidanceStrings.closeGuidanceDialogText,
      buttons,
    );
  }
}
