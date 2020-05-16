import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {

  final SharedPreferences prefs;
  final Serializers serializers;

  SharedPrefsServices(this.prefs, this.serializers);

  // All other methods depend on getString() and setString()
  Future<void> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  String getString(String key, [String defaultValue]) {
    return prefs.getString(key) ?? defaultValue;
  }


  Future<void> setInt(String key, int value) async {
    return prefs.setInt(key, value);
  }

  int getInt(String key, [int defaultValue]) {
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  bool getBool(String key, [bool defaultValue = false]) {
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setDateTime(String key, DateTime value) {
    return setString(key, value?.toIso8601String());
  }

  DateTime getDateTime(String key, [DateTime defaultValue]) {
    String strValue = getString(key);
    return strValue != null? DateTime.parse(strValue): defaultValue;
  }

  Future<void> setStringList(String key, List<String> value) {
    return prefs.setStringList(key, value);
  }

  List<String> getStringList<T>(String key, [List<String> defaultValue]) {
    return prefs.getStringList(key) ?? defaultValue;
  }

  Future<void> setObject<T>(String key, T obj, Serializer<T> serializer) {
    return setString(
        key, jsonEncode(serializers.serializeWith(serializer, obj)));
  }

  T getObject<T>(String key, Serializer<T> serializer, [T defaultValue]) {
    String value = getString(key);
    return value != null? serializers.deserializeWith(serializer, jsonDecode(value)): defaultValue;
  }

  Future<void> delete(String key) async {
    return prefs.remove(key);
  }

}
