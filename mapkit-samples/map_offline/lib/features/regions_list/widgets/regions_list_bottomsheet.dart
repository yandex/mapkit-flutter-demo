import 'package:flutter/material.dart';
import 'package:map_offline/features/regions_list/state/region_list_item.dart';
import 'package:map_offline/features/regions_list/widgets/region_item_widget.dart';
import 'package:map_offline/features/regions_list/widgets/region_section_widget.dart';

final class RegionsListBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  final List<RegionListItem> regionItems;
  final TextEditingController textEditingController;

  final void Function(String) onTextChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onClearButtonTapped;
  final void Function(int regionId) onRegionTapped;

  const RegionsListBottomSheet(
    this.scrollController, {
    super.key,
    required this.regionItems,
    required this.textEditingController,
    required this.onTextChanged,
    required this.onSubmitted,
    required this.onClearButtonTapped,
    required this.onRegionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              style: Theme.of(context).textTheme.labelMedium,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: onClearButtonTapped,
                      )
                    : null,
                labelStyle: Theme.of(context).textTheme.labelLarge,
                labelText: "Search",
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              onChanged: onTextChanged,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: regionItems
                    .map(
                      (item) => switch (item) {
                        final RegionItem region => RegionItemWidget(
                            regionName: region.name,
                            cities: region.cities.join(", "),
                            onTap: () => onRegionTapped(region.id),
                          ),
                        final SectionItem section => RegionSectionWidget(
                            sectionName: section.title,
                          ),
                      },
                    )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
