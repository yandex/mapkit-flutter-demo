import 'package:navikit_flutter_demo/core/resources/strings/alert_strings.dart';
import 'package:navikit_flutter_demo/domain/alerts/dialogs/dialogs_factory.dart';
import 'package:navikit_flutter_demo/domain/permissions/permission_manager.dart';
import 'package:permission_handler/permission_handler.dart';

final class PermissionManagerImpl implements PermissionManager {
  final DialogsFactory _dialogsFactory;

  const PermissionManagerImpl(this._dialogsFactory);

  @override
  Future<void> tryToRequest(List<PermissionType> permissions) async {
    final flutterPermissions = permissions.map((it) => it.mapPermission());

    flutterPermissions.permissionsForRequest().then((it) => it.request());
  }

  @override
  Future<void> showRequestDialog(List<PermissionType> permissions) async {
    final flutterPermissions = permissions.map((it) => it.mapPermission());

    flutterPermissions.permissionsForDialog().then((permissions) {
      if (permissions.isNotEmpty) {
        _dialogsFactory.showPermissionRequestDialog(
          description: AlertStrings.requestLocationPermissionDialogText,
          primaryAction: openAppSettings,
        );
      }
    });
  }

  @override
  Future<PermissionStatus> getPermissionStatus(
    PermissionType permission,
  ) async {
    return await permission.mapPermission().status;
  }
}

extension _MapPermission on PermissionType {
  Permission mapPermission() {
    return switch (this) {
      PermissionType.accessLocation => Permission.locationWhenInUse
    };
  }
}

extension _PermissionChecking on Iterable<Permission> {
  Future<List<Permission>> permissionsForRequest() async {
    final permissions = <Permission>[];
    for (final permission in this) {
      final isGranted = permission.isGranted;
      final isPermanentlyDenied = permission.isPermanentlyDenied;

      if (!(await isGranted) && !(await isPermanentlyDenied)) {
        permissions.add(permission);
      }
    }
    return permissions;
  }

  Future<List<Permission>> permissionsForDialog() async {
    final permissions = <Permission>[];
    for (final permission in this) {
      if (await permission.isPermanentlyDenied) {
        permissions.add(permission);
      }
    }
    return permissions;
  }
}
