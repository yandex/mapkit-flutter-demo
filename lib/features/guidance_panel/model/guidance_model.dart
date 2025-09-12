import 'package:yandex_maps_navikit/mapkit.dart';

final class GuidanceModel {
  final bool? isGuidanceActive;
  final bool? isSimulationActive;
  final String? roadName;
  final String? roadFlags;
  final Location? location;
  final LocalizedValue? distanceLeft;
  final LocalizedValue? timeWithTraffic;

  const GuidanceModel({
    required this.isGuidanceActive,
    required this.isSimulationActive,
    required this.roadName,
    required this.roadFlags,
    required this.location,
    required this.distanceLeft,
    required this.timeWithTraffic,
  });
}
