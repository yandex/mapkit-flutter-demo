import 'dart:math';

extension LetExtension<T> on T {
  R let<R>(R Function(T it) block) => block(this);
}

extension AlsoExtension<T> on T {
  T also(void Function(T it) block) {
    block(this);
    return this;
  }
}

extension TakeIf<T> on T {
  T? takeIf(bool Function(T it) condition) {
    return condition(this) ? this : null;
  }
}

extension TakeIfNotEmpty<T> on Iterable<T> {
  Iterable<T>? takeIfNotEmpty() => takeIf((it) => it.isNotEmpty);
}

extension Partition<T> on Iterable<T> {
  (List<T>, List<T>) partition(bool Function(T) predicate) {
    final firstList = <T>[];
    final secondList = <T>[];

    for (final item in this) {
      if (predicate(item)) {
        firstList.add(item);
      } else {
        secondList.add(item);
      }
    }
    return (firstList, secondList);
  }
}

extension Cast on dynamic {
  T? castOrNull<T>() => this is T ? this : null;
}

extension RandomExt<T> on List<T> {
  static final _random = Random();

  T random() {
    return this[_random.nextInt(length)];
  }
}

extension IsBlank on String? {
  bool get isBlank => this?.trim().isEmpty == true;
  bool get isNotBlank => this?.trim().isNotEmpty == true;
}
