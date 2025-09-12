import 'package:flutter/foundation.dart';

abstract interface class DialogsFactory {
  void showPermissionRequestDialog({
    required String description,
    required VoidCallback primaryAction,
  });

  void showRequestToPointDialog({
    required VoidCallback primaryAction,
  });

  void showRequestPointDialog({
    required VoidCallback onToClicked,
    required VoidCallback onViaClicked,
    required VoidCallback onFromClicked,
  });

  void showCancelGuidanceDialog({
    required VoidCallback primaryAction,
  });
}
