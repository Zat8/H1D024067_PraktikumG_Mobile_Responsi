import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../utils/weather_code.dart';
import '../viewmodels/weather_view_model.dart';
import 'search_screen.dart';

const _bgTop = Color(0xFF2B2468);
const _bgBottom = Color(0xFF7B5CE0);
const _glass = Color(0x26FFFFFF); // putih transparan
const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(vm.location?.name ?? 'Cuaca'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Muat ulang',
              onPressed: () => vm.refresh(),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Cari lokasi',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ],
        ),
        body: SafeArea(child: _buildBody(vm)),
      ),
    );
  }

  Widget _buildBody(WeatherViewModel vm) {
    // Loading
    if (vm.state == LoadState.idle || vm.state == LoadState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Error
    if (vm.state == LoadState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                vm.errorMessage ?? 'Terjadi kesalahan',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => vm.refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Data kosong
    final weather = vm.weather;
    final location = vm.location;
    if (weather == null || weather.daily.isEmpty || location == null) {
      return const Center(
        child: Text('Data cuaca kosong.', style: TextStyle(color: Colors.white)),
      );
    }

    return _WeatherContent(weather: weather, location: location);
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather, required this.location});

  final WeatherData weather;
  final Location location;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final today = weather.daily.first;
    final rainChance = today.precipitationProbability;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // Header cuaca
        Text(
          location.region,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          weatherCodeToEmoji(current.weatherCode),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 96),
        ),
        Text(
          '${current.temperature.round()}°',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          weatherCodeToText(current.weatherCode),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Maks ${today.tempMax.round()}° · Min ${today.tempMin.round()}° · '
              'Terasa ${current.apparentTemperature.round()}°',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),

        // Perkiraan 7 hari (bisa digeser ke samping)
        const _SectionTitle('Perkiraan 7 Hari'),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weather.daily.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _DayChip(
              forecast: weather.daily[i],
              isToday: i == 0,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Peluang hujan
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.umbrella, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Peluang Hujan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: rainChance / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC857)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$rainChance% kemungkinan hujan hari ini',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Terbit & Indeks UV
        Row(
          children: [
            Expanded(
              child: _GlassCard(
                child: _MiniInfo(
                  icon: Icons.wb_twilight,
                  label: 'Terbit',
                  value: _hhmm(weather.sunrise),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassCard(
                child: _MiniInfo(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Indeks UV',
                  value: weather.uvIndexMax.round().toString(),
                  sub: _uvText(weather.uvIndexMax),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Kelembapan, angin, curah hujan
        Row(
          children: [
            Expanded(
              child: _GlassCard(
                child: _MiniInfo(
                  icon: Icons.water_drop,
                  label: 'Kelembapan',
                  value: '${current.humidity}%',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassCard(
                child: _MiniInfo(
                  icon: Icons.air,
                  label: 'Angin',
                  value: '${current.windSpeed.toStringAsFixed(1)} km/j',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassCard(
                child: _MiniInfo(
                  icon: Icons.grain,
                  label: 'Hujan',
                  value: '${current.precipitation.toStringAsFixed(1)} mm',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// "2026-11-25T05:12" -> "05:12"
  String _hhmm(String? iso) {
    if (iso == null || !iso.contains('T')) return '-';
    final time = iso.split('T').last;
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  String _uvText(double uv) {
    if (uv < 3) return 'Rendah';
    if (uv < 6) return 'Sedang';
    if (uv < 8) return 'Tinggi';
    if (uv < 11) return 'Sangat Tinggi';
    return 'Ekstrem';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        if (sub != null)
          Text(
            sub!,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.forecast, required this.isToday});

  final DailyForecast forecast;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isToday ? 'Hari ini' : _days[forecast.date.weekday - 1],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            weatherCodeToEmoji(forecast.weatherCode),
            style: const TextStyle(fontSize: 28),
          ),
          Column(
            children: [
              Text(
                '${forecast.tempMax.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${forecast.tempMin.round()}°',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}