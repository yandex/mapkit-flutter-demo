import 'package:navikit_flutter_demo/utils/extension_utils.dart';
import 'package:yandex_maps_navikit/directions.dart';
import 'package:yandex_maps_navikit/mapkit.dart';

extension TimeWithTraffic on DrivingRoute {
  LocalizedValue timeWithTraffic() => metadata.weight.timeWithTraffic;
}

extension DistanceLeft on DrivingRoute {
  LocalizedValue distanceLeft() => metadata.weight.distance;
}

extension BuildFlagsString on DrivingRoute {
  String buildFlagsString() => metadata.flags.let((it) {
        return [
          _flagBlocked.takeIf((_) => it.blocked),
          _flagBuiltOffline.takeIf((_) => it.builtOffline),
          _flagHasCheckpoints.takeIf((_) => it.hasCheckpoints),
          _flagForParking.takeIf((_) => it.forParking),
          _flagHasFerries.takeIf((_) => it.hasFerries),
          _flagHasFordCrossing.takeIf((_) => it.hasFordCrossing),
          _flagHasRuggedRoads.takeIf((_) => it.hasRuggedRoads),
          _flagHasTolls.takeIf((_) => it.hasTolls),
          _flagHasVehicleRestrictions.takeIf((_) => it.hasVehicleRestrictions),
          _flagPredicted.takeIf((_) => it.predicted),
          _flagRequiresAccessPass.takeIf((_) => it.requiresAccessPass),
        ].nonNulls.join(" ");
      });

  static final String _flagBlocked = String.fromCharCodes([0x26d4], 0, 1); // ⛔
  static final String _flagBuiltOffline =
      String.fromCharCodes([0x2708, 0xfe0f], 0, 2); // ✈️
  static final String _flagHasCheckpoints =
      String.fromCharCodes([0x1f6c3], 0, 1); //  🛃
  static final String _flagForParking =
      String.fromCharCodes([0x1f17f, 0xfe0f], 0, 2); // 🅿️
  static final String _flagHasFerries =
      String.fromCharCodes([0x26f4, 0xfe0f], 0, 2); // ⛴️
  static final String _flagHasFordCrossing =
      String.fromCharCodes([0x1f3ca], 0, 1); // 🏊
  static final String _flagHasRuggedRoads =
      String.fromCharCodes([0x26a0, 0xfe0f], 0, 2); // ⚠️
  static final String _flagHasTolls =
      String.fromCharCodes([0x1f4b0], 0, 1); // 💰
  static final String _flagHasVehicleRestrictions =
      String.fromCharCodes([0x1f69b], 0, 1); // 🚛
  static final String _flagPredicted =
      String.fromCharCodes([0x1f52e], 0, 1); // 🔮
  static final String _flagRequiresAccessPass =
      String.fromCharCodes([0x1f510], 0, 1); // 🔐
}
