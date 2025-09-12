import 'package:yandex_maps_navikit/navigation.dart';

abstract interface class NavigationSerializer {
  void serializeNavigation(Navigation navigation);
  Navigation? deserializeNavigationFromSettings();
}
