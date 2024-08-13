import 'dart:async';

import 'package:navikit_flutter_demo/domain/settings/settings_manager.dart';
import 'package:navikit_flutter_demo/domain/storage/key_value_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final class SettingsManagerImpl implements SettingsManager {
  final KeyValueStorage _keyValueStorage;

  SettingsManagerImpl(this._keyValueStorage);

  @override
  late final restoreGuidanceState =
      _boolean("restoreGuidanceState", defaultValue: true);

  @override
  late final serializedNavigation = _string("serializedNavigation");

  SettingsModel<bool> _boolean(String key, {bool defaultValue = false}) {
    return _SettingsModelImpl(
      key,
      putValue: _keyValueStorage.putBool,
      getPreference: (key) => _keyValueStorage.readBool(key, defaultValue),
    );
  }

  SettingsModel<String> _string(String key, {String defaultValue = ""}) {
    return _SettingsModelImpl(
      key,
      putValue: _keyValueStorage.putString,
      getPreference: (key) => _keyValueStorage.readString(key, defaultValue),
    );
  }
}

final class _SettingsModelImpl<T> implements SettingsModel<T> {
  final String _key;
  final void Function(String key, T value) putValue;
  final Preference<T> Function(String key) getPreference;

  late final _preferenceValue = getPreference(_key);
  late final _changes = _preferenceValue.share();

  _SettingsModelImpl(
    this._key, {
    required this.putValue,
    required this.getPreference,
  });

  @override
  T get value => _preferenceValue.getValue();

  @override
  void setValue(T newValue) {
    putValue(_key, newValue);
  }

  @override
  Stream<T> get changes => _changes;
}
