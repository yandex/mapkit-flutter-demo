import 'package:yandex_maps_mapkit/runtime.dart';

sealed class SetCachePathState {}

final class SetCachePathUndefined extends SetCachePathState {
  static SetCachePathUndefined instance = SetCachePathUndefined._();

  SetCachePathUndefined._();
}

final class SetCachePathSuccess extends SetCachePathState {
  static SetCachePathSuccess instance = SetCachePathSuccess._();

  SetCachePathSuccess._();
}

final class SetCachePathError extends SetCachePathState {
  final Error error;

  SetCachePathError(this.error);
}
