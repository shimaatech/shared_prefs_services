import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {
  static const expirationSuffix = '.expiration';

  final SharedPreferences prefs;
  final Serializers serializers;

  SharedPrefsServices(this.prefs, this.serializers);

  Future<void> setString(String key, String value, {Duration expiration}) {
    return Future.wait([
      prefs.setString(key, value),
      _setExpiration(key, expiration),
    ]);
  }

  String getString(String key, [String defaultValue]) {
    String value = prefs.getString(key);
    return value != null && !isExpired(key) ? value : defaultValue;
  }

  Future<void> setInt(String key, int value, {Duration expiration}) {
    return Future.wait([
      prefs.setInt(key, value),
      _setExpiration(key, expiration),
    ]);
  }

  int getInt(String key, [int defaultValue]) {
    int value = prefs.getInt(key);
    return value != null && !isExpired(key) ? value : defaultValue;
  }

  Future<void> setBool(String key, bool value, {Duration expiration}) {
    return Future.wait([
      prefs.setBool(key, value),
      _setExpiration(key, expiration),
    ]);
  }

  bool getBool(String key, [bool defaultValue = false]) {
    bool value = prefs.getBool(key);
    return value != null && !isExpired(key) ? value : defaultValue;
  }

  Future<void> setDateTime(String key, DateTime value, {Duration expiration}) {
    return setString(key, value?.toIso8601String(), expiration: expiration);
  }

  DateTime getDateTime(String key, [DateTime defaultValue]) {
    String strValue = getString(key);
    return strValue != null && !isExpired(key)
        ? DateTime.parse(strValue)
        : defaultValue;
  }

  Future<void> setStringList(String key, List<String> value,
      {Duration expiration}) {
    return Future.wait([
      prefs.setStringList(key, value),
      _setExpiration(key, expiration),
    ]);
  }

  List<String> getStringList<T>(String key, [List<String> defaultValue]) {
    List<String> value = prefs.getStringList(key);
    return value != null && !isExpired(key) ? value : defaultValue;
  }

  Future<void> setIntList(String key, List<int> value, {Duration expiration}) {
    return setStringList(key, value.map((e) => e.toString()).toList());
  }

  List<int> getIntList(String key, [List<int> defaultValue]) {
    List<String> strList = getStringList(key);
    return strList != null
        ? strList.map((e) => int.parse(e)).toList()
        : defaultValue;
  }

  Future<void> setObject<T>(String key, T obj, Serializer<T> serializer,
      {Duration expiration}) {
    return setString(
        key, jsonEncode(serializers.serializeWith(serializer, obj)),
        expiration: expiration);
  }

  T getObject<T>(String key, Serializer<T> serializer, [T defaultValue]) {
    String value = getString(key);
    return value != null && !isExpired(key)
        ? serializers.deserializeWith(serializer, jsonDecode(value))
        : defaultValue;
  }

  Future<void> delete(String key) async {
    return Future.wait([
      prefs.remove(key),
      prefs.remove(_getExpirationKey(key)),
    ]);
  }

  bool isExpired(String key) {
    assert(key != null);
    DateTime expirationDate = getDateTime(_getExpirationKey(key));
    if (expirationDate == null) {
      return false;
    }
    return DateTime.now().isAfter(expirationDate);
  }

  String _getExpirationKey(String key) {
    return key + expirationSuffix;
  }

  Future<void> _setExpiration(String key, Duration expiration) async {
    if (expiration == null) {
      return;
    }
    assert(key != null);
    return setDateTime(_getExpirationKey(key), DateTime.now().add(expiration));
  }
}
