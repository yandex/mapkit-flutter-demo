abstract interface class DialogsFactory {
  void showPermissionRequestDialog({
    required String description,
    required void Function() primaryAction,
  });

  void showRequestToPointDialog({
    required void Function() primaryAction,
  });

  void showRequestPointDialog({
    required void Function() onToClicked,
    required void Function() onViaClicked,
    required void Function() onFromClicked,
  });

  void showCancelGuidanceDialog({
    required void Function() primaryAction,
  });
}
