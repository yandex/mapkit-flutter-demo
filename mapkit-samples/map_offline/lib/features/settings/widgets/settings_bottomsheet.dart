import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:map_offline/features/settings/state/settings_ui_state.dart';

final class SettingsBottomSheet extends StatelessWidget {
  final SettingsUiState settingsUiState;
  final TextEditingController textEditingController;
  final void Function(bool?) onAllowCellularNetworkButtonTapped;
  final void Function(bool?) onAutoUpdateButtonTapped;
  final VoidCallback onShowCacheSizeButtonTapped;
  final VoidCallback onClearCacheButtonTapped;
  final VoidCallback onMoveCacheButtonTapped;
  final VoidCallback onSwitchPathButtonTapped;

  const SettingsBottomSheet(
    this.textEditingController, {
    super.key,
    required this.settingsUiState,
    required this.onAllowCellularNetworkButtonTapped,
    required this.onAutoUpdateButtonTapped,
    required this.onShowCacheSizeButtonTapped,
    required this.onClearCacheButtonTapped,
    required this.onMoveCacheButtonTapped,
    required this.onSwitchPathButtonTapped,
  });

  @override
  Widget build(BuildContext context) {
    final moveCacheProgress = settingsUiState.moveCacheProgress;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0,
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Allow cellular network",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Checkbox(
                  value: settingsUiState.allowUseCellularNetwork,
                  onChanged: onAllowCellularNetworkButtonTapped,
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => _getCheckboxColor(context, states),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enable auto update",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Checkbox(
                  value: settingsUiState.autoUpdateEnabled,
                  onChanged: onAutoUpdateButtonTapped,
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => _getCheckboxColor(context, states),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 10.0,
              children: [
                SimpleButton(
                  text: "Cache size",
                  onPressed: onShowCacheSizeButtonTapped,
                ),
                SimpleButton(
                  text: "Clear cache",
                  onPressed: onClearCacheButtonTapped,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              "Caches path:",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextField(
              controller: textEditingController,
              style: Theme.of(context).textTheme.labelMedium,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              maxLines: 2,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 10.0,
              children: [
                SimpleButton(
                  text: "Move data",
                  onPressed: onMoveCacheButtonTapped,
                ),
                SimpleButton(
                  text: "Switch path",
                  onPressed: onSwitchPathButtonTapped,
                ),
              ],
            ),
            if (moveCacheProgress != null) ...[
              const SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: moveCacheProgress.toDouble(),
                color: Theme.of(context).colorScheme.secondary,
                minHeight: 10.0,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCheckboxColor(BuildContext context, Set<MaterialState> states) {
    if (states.any((element) => element == MaterialState.selected)) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Colors.white;
  }
}
