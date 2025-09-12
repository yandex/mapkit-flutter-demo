abstract interface class SettingsModel<T> {
  T get value;
  void setValue(T newValue);
  Stream<T> get changes;
}

abstract interface class SettingsManager {
  // Guidance
  SettingsModel<bool> get restoreGuidanceState;
  SettingsModel<String> get serializedNavigation;
}
