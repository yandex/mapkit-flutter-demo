sealed class RegionListItem {}

final class RegionItem extends RegionListItem {
  final int id;
  final String name;
  final List<String> cities;

  RegionItem({
    required this.id,
    required this.name,
    required this.cities,
  });

  @override
  String toString() => "RegionItem(id=$id, name=$name, cities=$cities)";
}

final class SectionItem extends RegionListItem {
  final String title;

  SectionItem({required this.title});
}
