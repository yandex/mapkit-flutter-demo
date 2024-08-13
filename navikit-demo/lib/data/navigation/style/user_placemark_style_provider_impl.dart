import 'package:yandex_maps_navikit/mapkit.dart';
import 'package:yandex_maps_navikit/navigation.dart';

final class UserPlacemarkStyleProviderImpl
    implements NavigationUserPlacemarkStyleProvider {
  @override
  void provideStyle(
    double scaleFactor,
    bool isNightMode,
    PlacemarkStyle style,
  ) {
    style.setArrowModel();
  }
}
