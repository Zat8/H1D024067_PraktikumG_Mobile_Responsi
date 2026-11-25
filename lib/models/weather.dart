class CurrentWeather {
  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int precipitationProbability;
  final int weatherCode;
}

class WeatherData {
  WeatherData({
    required this.current,
    required this.daily,
    this.sunrise,
    this.sunset,
    this.uvIndexMax = 0,
  });

  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String? sunrise; // format ISO, contoh "2026-11-25T05:12"
  final String? sunset;
  final double uvIndexMax;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final times = (dailyJson['time'] as List).cast<String>();
    final codes = dailyJson['weather_code'] as List;
    final maxs = dailyJson['temperature_2m_max'] as List;
    final mins = dailyJson['temperature_2m_min'] as List;
    final probs = dailyJson['precipitation_probability_max'] as List;

    final daily = List.generate(
      times.length,
          (i) => DailyForecast(
        date: DateTime.parse(times[i]),
        tempMax: (maxs[i] as num).toDouble(),
        tempMin: (mins[i] as num).toDouble(),
        precipitationProbability: (probs[i] as num?)?.toInt() ?? 0,
        weatherCode: (codes[i] as num).toInt(),
      ),
    );

    final sunrises = dailyJson['sunrise'] as List?;
    final sunsets = dailyJson['sunset'] as List?;
    final uvs = dailyJson['uv_index_max'] as List?;

    return WeatherData(
      current: CurrentWeather.fromJson(currentJson),
      daily: daily,
      sunrise: sunrises?.isNotEmpty == true ? sunrises!.first as String? : null,
      sunset: sunsets?.isNotEmpty == true ? sunsets!.first as String? : null,
      uvIndexMax: uvs?.isNotEmpty == true
          ? (uvs!.first as num?)?.toDouble() ?? 0
          : 0,
    );
  }
}