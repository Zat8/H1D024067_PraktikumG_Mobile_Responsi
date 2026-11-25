import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../services/local_storage.dart';
import '../services/weather_service.dart';

enum LoadState { idle, loading, success, error }

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._service, this._storage);

  final WeatherService _service;
  final LocalStorage _storage;

  static const defaultLocation = Location(
    name: 'Jakarta',
    country: 'Indonesia',
    admin1: 'DKI Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
  );

  Location? _location;
  WeatherData? _weather;
  LoadState _state = LoadState.idle;
  String? _errorMessage;

  Location? get location => _location;
  WeatherData? get weather => _weather;
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Dipanggil saat app dibuka: pakai lokasi terakhir atau default
  Future<void> init() async {
    final last = await _storage.loadLastLocation();
    _location = last ?? defaultLocation;
    await refresh();
  }

  Future<void> selectLocation(Location location) async {
    _location = location;
    await _storage.saveLastLocation(location);
    await refresh();
  }

  Future<void> refresh() async {
    final loc = _location;
    if (loc == null) return;

    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _service.fetchWeather(loc);
      _state = LoadState.success;
    } catch (e) {
      debugPrint('Error fetch weather: $e');
      _weather = null;
      _state = LoadState.error;
      _errorMessage = 'Gagal memuat data cuaca. Periksa koneksi internet lalu coba lagi.';
    }

    notifyListeners();
  }
}