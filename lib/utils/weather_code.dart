import 'package:flutter/material.dart';

/// Mengubah kode WMO dari Open-Meteo menjadi teks Bahasa Indonesia.
String weatherCodeToText(int code) {
  if (code == 0) return 'Cerah';
  if (code == 1) return 'Sebagian Cerah';
  if (code == 2) return 'Berawan Sebagian';
  if (code == 3) return 'Berawan';
  if (code == 45 || code == 48) return 'Berkabut';
  if (code >= 51 && code <= 57) return 'Gerimis';
  if (code >= 61 && code <= 67) return 'Hujan';
  if (code >= 71 && code <= 77) return 'Salju';
  if (code >= 80 && code <= 82) return 'Hujan Lokal';
  if (code >= 85 && code <= 86) return 'Salju Lokal';
  if (code >= 95) return 'Badai Petir';
  return 'Tidak Diketahui';
}

IconData weatherCodeToIcon(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code == 1) return Icons.wb_cloudy;
  if (code == 2 || code == 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 51 && code <= 57) return Icons.grain;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return Icons.umbrella;
  }
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
    return Icons.ac_unit;
  }
  if (code >= 95) return Icons.thunderstorm;
  return Icons.help_outline;
}

String weatherCodeToEmoji(int code) {
  if (code == 0) return '☀️';
  if (code == 1) return '🌤️';
  if (code == 2) return '⛅';
  if (code == 3) return '☁️';
  if (code == 45 || code == 48) return '🌫️';
  if (code >= 51 && code <= 57) return '🌦️';
  if (code >= 61 && code <= 67) return '🌧️';
  if (code >= 71 && code <= 77) return '❄️';
  if (code >= 80 && code <= 82) return '🌧️';
  if (code >= 85 && code <= 86) return '🌨️';
  if (code >= 95) return '⛈️';
  return '❔';
}