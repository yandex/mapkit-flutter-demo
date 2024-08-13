final class SettingsUiState {
  final String cachesPath;
  final bool allowUseCellularNetwork;
  final bool autoUpdateEnabled;
  final int? moveCacheProgress;

  const SettingsUiState({
    required this.cachesPath,
    this.allowUseCellularNetwork = false,
    this.autoUpdateEnabled = false,
    this.moveCacheProgress,
  });
}
