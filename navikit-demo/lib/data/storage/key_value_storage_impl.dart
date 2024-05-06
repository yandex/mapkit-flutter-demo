import 'package:navikit_flutter_demo/domain/storage/key_value_storage.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

final class KeyValueStorageImpl implements KeyValueStorage {
  late final StreamingSharedPreferences _sharedPrefs;

  @override
  Future<void> initStorage() async {
    _sharedPrefs = await StreamingSharedPreferences.instance;
  }

  @override
  void putString(String key, String value) async {
    _sharedPrefs.setString(key, value);
  }

  @override
  Preference<String> readString(String key, String defaultValue) {
    return _sharedPrefs.getString(key, defaultValue: defaultValue);
  }

  @override
  void putBool(String key, bool value) {
    _sharedPrefs.setBool(key, value);
  }

  @override
  Preference<bool> readBool(String key, bool defaultValue) {
    return _sharedPrefs.getBool(key, defaultValue: defaultValue);
  }
}
