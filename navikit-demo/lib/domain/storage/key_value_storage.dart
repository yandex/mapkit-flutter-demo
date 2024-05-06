import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

abstract interface class KeyValueStorage {
  Future<void> initStorage();

  void putString(String key, String value);
  Preference<String> readString(String key, String defaultValue);

  void putBool(String key, bool value);
  Preference<bool> readBool(String key, bool defaultValue);
}
