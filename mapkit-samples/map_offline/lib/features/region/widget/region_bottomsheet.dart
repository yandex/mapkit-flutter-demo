import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:map_offline/features/region/state/region_ui_state.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class RegionsBottomSheet extends StatelessWidget {
  final RegionUiState regionUiState;
  final VoidCallback onShowButtonTap;
  final VoidCallback onStartDownloadButtonTapped;
  final VoidCallback onStopDownloadButtonTapped;
  final VoidCallback onPauseDownloadButtonTapped;
  final VoidCallback onDropDownloadButtonTapped;

  static const _regionStatesWhenProgressBarIsVisible = [
    OfflineCacheRegionState.Downloading,
    OfflineCacheRegionState.Paused,
  ];

  const RegionsBottomSheet({
    super.key,
    required this.regionUiState,
    required this.onShowButtonTap,
    required this.onStartDownloadButtonTapped,
    required this.onStopDownloadButtonTapped,
    required this.onPauseDownloadButtonTapped,
    required this.onDropDownloadButtonTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Id: ${regionUiState.id}",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              "Name: ${regionUiState.name}",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10.0),
            Text(
              "Country: ${regionUiState.country}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Cities: ${regionUiState.cities}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Parent id: ${regionUiState.parentId}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Center: (${regionUiState.center.latitude}, ${regionUiState.center.longitude})",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SimpleButton(
                  text: "Show",
                  onPressed: onShowButtonTap,
                )
              ],
            ),
            const SizedBox(height: 10.0),
            const Divider(thickness: 1.0),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 10.0,
              children: [
                SimpleButton(
                  text: "Start",
                  onPressed: onStartDownloadButtonTapped,
                ),
                SimpleButton(
                  text: "Stop",
                  onPressed: onStopDownloadButtonTapped,
                ),
                SimpleButton(
                  text: "Pause",
                  onPressed: onPauseDownloadButtonTapped,
                ),
                SimpleButton(
                  text: "Drop",
                  onPressed: onDropDownloadButtonTapped,
                ),
              ],
            ),
            if (_regionStatesWhenProgressBarIsVisible
                .contains(regionUiState.state)) ...[
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: regionUiState.downloadProgress,
                color: Theme.of(context).colorScheme.secondary,
                minHeight: 10.0,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              const SizedBox(height: 8.0),
            ] else ...[
              const SizedBox(height: 10.0)
            ],
            Text(
              "State: ${regionUiState.state.name.toUpperCase()}",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              "Size: ${regionUiState.size}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Release time: ${regionUiState.releaseTime}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Downloaded time: ${regionUiState.downloadedReleaseTime}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
