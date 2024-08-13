import 'package:yandex_maps_mapkit/runtime.dart';

sealed class MoveCacheState {}

final class MoveCacheUndefined extends MoveCacheState {
  static MoveCacheUndefined instance = MoveCacheUndefined._();

  MoveCacheUndefined._();
}

final class MoveCacheCompleted extends MoveCacheState {
  static MoveCacheCompleted instance = MoveCacheCompleted._();

  MoveCacheCompleted._();
}

final class MoveCacheInProgress extends MoveCacheState {
  final int progress;

  MoveCacheInProgress(this.progress);
}

final class MoveCacheError extends MoveCacheState {
  final Error error;

  MoveCacheError(this.error);
}
