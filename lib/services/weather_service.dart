import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Pencarian kota -> GET ke Geocoding API
  Future<List<Location>> searchLocations(String query) async {
    final uri = Uri.parse(_geocodingUrl).replace(queryParameters: {
      'name': query,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final response =
    await _client.get(uri).timeout(const Duration(seconds: 15));
    _ensureOk(response);

    final body = json.decode(response.body) as Map<String, dynamic>;
    // Jika kota tidak ditemukan, field "results" tidak ada di response
    final results = body['results'] as List<dynamic>? ?? [];

    return results
        .map((e) => Location.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil cuaca untuk satu lokasi -> GET ke Forecast API
  Future<WeatherData> fetchWeather(Location location) async {
    final uri = Uri.parse(_forecastUrl).replace(queryParameters: {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current':
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max',
      'timezone': 'auto',
    });

    final response =
    await _client.get(uri).timeout(const Duration(seconds: 15));
    _ensureOk(response);

    return WeatherData.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}