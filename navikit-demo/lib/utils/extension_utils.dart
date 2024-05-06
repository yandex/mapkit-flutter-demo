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

extension Cast on dynamic {
  T? castOrNull<T>() => this is T ? this : null;
}
