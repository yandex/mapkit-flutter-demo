import 'package:map_with_user_placemark/dialogs/dialogs_factory.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType {
  accessLocation,
}

final class PermissionManager {
  final DialogsFactory _dialogsFactory;

  const PermissionManager(this._dialogsFactory);

  Future<void> tryToRequest(List<PermissionType> permissions) async {
    final flutterPermissions = permissions.map((it) => it.mapPermission());

    flutterPermissions.permissionsForRequest().then((it) => it.request());
  }

  Future<void> showRequestDialog(List<PermissionType> permissions) async {
    final flutterPermissions = permissions.map((it) => it.mapPermission());

    flutterPermissions.permissionsForDialog().then((permissions) {
      if (permissions.isNotEmpty) {
        _dialogsFactory.showPermissionRequestDialog(
          description: "Please, let us access your exact location.",
          primaryAction: openAppSettings,
        );
      }
    });
  }

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
