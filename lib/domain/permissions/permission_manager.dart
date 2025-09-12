import 'package:permission_handler/permission_handler.dart';

abstract interface class PermissionManager {
  Future<void> tryToRequest(List<PermissionType> permissions);
  Future<void> showRequestDialog(List<PermissionType> permissions);
  Future<PermissionStatus> getPermissionStatus(PermissionType permission);
}

enum PermissionType {
  accessLocation,
}
