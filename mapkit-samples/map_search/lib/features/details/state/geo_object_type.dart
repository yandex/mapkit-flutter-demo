sealed class GeoObjectType {}

final class UndefinedGeoObject extends GeoObjectType {
  static final instance = UndefinedGeoObject._();

  UndefinedGeoObject._();

  @override
  String toString() => "Undefined";
}

final class ToponymGeoObject extends GeoObjectType {
  final String address;

  ToponymGeoObject({required this.address});

  @override
  String toString() => "Toponym";
}

final class BusinessGeoObject extends GeoObjectType {
  final String name;
  final String? workingHours;
  final String? categories;
  final String? phones;
  final String? link;

  BusinessGeoObject({
    required this.name,
    required this.workingHours,
    required this.categories,
    required this.phones,
    required this.link,
  });

  @override
  String toString() => "Business";
}
