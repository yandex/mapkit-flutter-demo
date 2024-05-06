import 'dart:typed_data';

import 'package:navikit_flutter_demo/domain/navigation/serialization/navigation_serializer.dart';
import 'package:navikit_flutter_demo/domain/settings/settings_manager.dart';
import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class NavigationSerializerImpl implements NavigationSerializer {
  final SettingsManager _settingsManager;

  NavigationSerializerImpl(this._settingsManager);

  @override
  void serializeNavigation(Navigation navigation) {
    final serializedNavigation = NavigationSerialization.serialize(navigation);
    final bytesAsChars =
        String.fromCharCodes(serializedNavigation.asUint8List());
    _settingsManager.serializedNavigation.setValue(bytesAsChars);
  }

  @override
  Navigation? deserializeNavigationFromSettings() {
    return _settingsManager.serializedNavigation.value.let((navigation) {
      if (navigation.isNotEmpty) {
        final bytes = Uint8List.fromList(navigation.codeUnits);
        return NavigationSerialization.deserialize(bytes.buffer);
      } else {
        return null;
      }
    });
  }
}
