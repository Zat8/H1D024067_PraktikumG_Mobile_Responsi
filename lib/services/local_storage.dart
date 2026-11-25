import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

class LocalStorage {
  static const _favoritesKey = 'favorite_locations';
  static const _lastLocationKey = 'last_location';

  Future<List<Location>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((s) => Location.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<Location> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      favorites.map((l) => json.encode(l.toJson())).toList(),
    );
  }

  Future<Location?> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null) return null;
    return Location.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(Location location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, json.encode(location.toJson()));
  }
}