import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:map_offline/features/settings/managers/listeners/offline_cache_move_listener.dart';
import 'package:map_offline/features/settings/state/move_cache_state.dart';
import 'package:map_offline/features/settings/state/set_cache_path_state.dart';
import 'package:map_offline/features/settings/state/settings_ui_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';

final class SettingsManager {
  SettingsManager(this._offlineCacheManager);

  static const _allowUseCellularNetworkKey = "allowUseCellularNetwork";
  static const _autoUpdateEnabledKey = "autoUpdateEnabled";

  final OfflineCacheManager _offlineCacheManager;

  late final _cachesPath = BehaviorSubject<String>()..add("");
  late final _moveCacheState = BehaviorSubject<MoveCacheState>()
    ..add(MoveCacheUndefined.instance);
  late final _setCachePathState = BehaviorSubject<SetCachePathState>()
    ..add(SetCachePathUndefined.instance);
  late final _useCellularNetwork = BehaviorSubject<bool>()
    ..add(_sharedPreferences.getBool(_allowUseCellularNetworkKey) ?? false);
  late final _autoUpdateEnabled = BehaviorSubject<bool>()
    ..add(_sharedPreferences.getBool(_autoUpdateEnabledKey) ?? false);

  late final _uiState = Rx.combineLatest4(
    _cachesPath.distinctUnique(),
    _useCellularNetwork,
    _autoUpdateEnabled,
    _moveCacheState,
    (cachesPath, allowUseCellularNetwork, autoUpdateEnabled, moveCacheState) {
      _offlineCacheManager.allowUseCellularNetwork(allowUseCellularNetwork);
      _offlineCacheManager.enableAutoUpdate(autoUpdateEnabled);

      _sharedPreferences
        ..setBool(_allowUseCellularNetworkKey, allowUseCellularNetwork)
        ..setBool(_autoUpdateEnabledKey, autoUpdateEnabled);

      final moveCacheProgress =
          moveCacheState.castOrNull<MoveCacheInProgress>()?.progress;

      return SettingsUiState(
        cachesPath: cachesPath,
        allowUseCellularNetwork: allowUseCellularNetwork,
        autoUpdateEnabled: autoUpdateEnabled,
        moveCacheProgress: moveCacheProgress,
      );
    },
  ).publishValue();

  late final _offlineCacheDataMoveListener = OfflineCacheDataMoveListenerImpl(
    onDataMoveProgressCallback: (progress) {
      _moveCacheState.add(MoveCacheInProgress(progress));
    },
    onDataMoveCompletedCallback: () {
      _moveCacheState.add(MoveCacheCompleted.instance);
    },
    onDataMoveErrorCallback: (error) {
      _moveCacheState.add(MoveCacheError(error));
    },
  );

  late final _offlineCachePathSetterListener =
      OfflineCacheManagerPathSetterListener(
          onPathSet: () => _setCachePathState.add(SetCachePathSuccess.instance),
          onPathSetError: (error) => _setCachePathState.add(
                SetCachePathError(error),
              ));

  late final SharedPreferences _sharedPreferences;

  ValueConnectableStream<SettingsUiState> get uiState => _uiState;
  Stream<MoveCacheState> get moveCacheState => _moveCacheState;
  Stream<SetCachePathState> get setCachePathState => _setCachePathState;

  Future<void> initStorage() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void startListening() {
    _offlineCacheManager.requestPath(
      OfflineCacheManagerPathGetterListener(onPathReceived: _cachesPath.add),
    );
  }

  void computeCacheSize(void Function(int?) onSizeComputed) {
    _offlineCacheManager.computeCacheSize(
        OfflineCacheManagerSizeListener(onSizeComputed: onSizeComputed));
  }

  void clearCache(VoidCallback onClearCompleted) {
    _offlineCacheManager.clear(
      OfflineCacheManagerClearListener(onClearCompleted: onClearCompleted),
    );
  }

  void moveCache(String path) {
    _cachesPath.add(path);
    _offlineCacheManager.moveData(_offlineCacheDataMoveListener, newPath: path);
  }

  void setCachePath(String path) {
    _cachesPath.add(path);
    _offlineCacheManager.setCachePath(
      _offlineCachePathSetterListener,
      path: path,
    );
  }

  void setUseCellularNetwork(bool value) => _useCellularNetwork.add(value);
  void setAutoUpdateEnabled(bool value) => _autoUpdateEnabled.add(value);
}
