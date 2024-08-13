import 'package:flutter/foundation.dart';
import 'package:yandex_maps_mapkit/mapkit.dart';
import 'package:yandex_maps_mapkit/runtime.dart';

final class OfflineCacheDataMoveListenerImpl
    implements OfflineCacheDataMoveListener {
  final void Function(int progress) onDataMoveProgressCallback;
  final VoidCallback onDataMoveCompletedCallback;
  final void Function(Error error) onDataMoveErrorCallback;

  const OfflineCacheDataMoveListenerImpl({
    required this.onDataMoveProgressCallback,
    required this.onDataMoveCompletedCallback,
    required this.onDataMoveErrorCallback,
  });

  @override
  void onDataMoveProgress(int percent) => onDataMoveProgressCallback(percent);

  @override
  void onDataMoveCompleted() => onDataMoveCompletedCallback();

  @override
  void onDataMoveError(Error error) => onDataMoveErrorCallback(error);
}
