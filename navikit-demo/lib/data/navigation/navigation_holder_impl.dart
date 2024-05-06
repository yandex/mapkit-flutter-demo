import 'dart:developer';

import 'package:navikit_flutter_demo/core/resources/strings/logs_strings.dart';
import 'package:navikit_flutter_demo/domain/alerts/snackbars/snackbar_factory.dart';
import 'package:navikit_flutter_demo/domain/navigation/navigation_holder.dart';
import 'package:navikit_flutter_demo/domain/navigation/serialization/navigation_serializer.dart';
import 'package:navikit_flutter_demo/domain/settings/settings_manager.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationHolderImpl implements NavigationHolder {
  final SettingsManager _settingsManager;
  final NavigationSerializer _navigationSerializer;
  final SnackBarFactory _snackBarFactory;

  late final _navigationImpl = _create();

  NavigationHolderImpl(
    this._settingsManager,
    this._navigationSerializer,
    this._snackBarFactory,
  );

  @override
  Navigation get navigation => _navigationImpl;

  @override
  void serialize() {
    _navigationSerializer.serializeNavigation(_navigationImpl);
    log(LogsStrings.navigationWasSerializedLog);
    _snackBarFactory.showSnackBar(LogsStrings.navigationWasSerializedLog);
  }

  Navigation _create() {
    if (_settingsManager.restoreGuidanceState.value) {
      final navigation =
          _navigationSerializer.deserializeNavigationFromSettings();

      if (navigation != null) {
        _settingsManager.serializedNavigation.setValue("");
        log(LogsStrings.deserializedNavigationLog);

        return navigation;
      } else {
        log(LogsStrings.failedToDeserializeNavigationLog);
      }
    }
    return NavigationFactory.createNavigation(DrivingRouterType.Combined);
  }
}
