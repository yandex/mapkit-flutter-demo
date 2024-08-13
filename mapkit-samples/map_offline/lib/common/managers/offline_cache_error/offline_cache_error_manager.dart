import 'package:common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:map_offline/common/managers/listener_manager.dart';
import 'package:map_offline/common/managers/offline_cache_error/offline_cache_error_listener.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/runtime.dart';

final class OfflineCacheErrorManager implements ListenerManager {
  final OfflineCacheManager offlineCacheManager;
  final BuildContext? Function() contextProvider;

  late final _offlineCacheErrorListener = OfflineCacheErrorListenerImpl(
    onErrorCallback: (error) => _showErrorSnackbar(error),
    onRegionErrorCallback: (error, regionId) {
      _showErrorSnackbar(error, regionId);
    },
  );

  OfflineCacheErrorManager(
    this.offlineCacheManager,
    this.contextProvider,
  );

  @override
  void startListening() {
    offlineCacheManager.addErrorListener(_offlineCacheErrorListener);
  }

  @override
  void dispose() {
    offlineCacheManager.removeErrorListener(_offlineCacheErrorListener);
  }

  void _showErrorSnackbar(Error error, [int? regionId]) {
    final errorType = switch (error) {
      final LocalError _ => "Local",
      final RemoteError _ => "Remote",
      _ => "Unknown",
    };

    final snackbarText = regionId == null
        ? "$errorType error in OfflineCacheManager"
        : "$errorType error when process region with $regionId id";

    contextProvider()?.let((context) => showSnackBar(context, snackbarText));
  }
}
