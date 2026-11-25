import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/local_storage.dart';
import 'services/weather_service.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/weather_view_model.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<LocalStorage>(create: (_) => LocalStorage()),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (context) => WeatherViewModel(
            context.read<WeatherService>(),
            context.read<LocalStorage>(),
          )..init(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (context) => SearchViewModel(
            context.read<WeatherService>(),
            context.read<LocalStorage>(),
          )..loadFavorites(),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecasts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BDB)),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomeScreen(),
    );
  }
}