import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:map_search/features/details/state/details_bottomsheet_ui_state.dart';

final class DetailsBottomSheet extends StatelessWidget {
  final DetailsBottomSheetUiState uiState;

  const DetailsBottomSheet({super.key, required this.uiState});

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1.1,
      child: Align(
        alignment: Alignment.topLeft,
        heightFactor: 1.1,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uiState.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12.0),
              Text(
                uiState.description,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                uiState.location
                        ?.let((it) => "${it.latitude}, ${it.longitude}") ??
                    "",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12.0),
              Text(
                "Type: ${uiState.geoObjectType}",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                "Uri: ${uiState.uri}",
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
