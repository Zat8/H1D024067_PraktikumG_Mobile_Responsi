import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../services/local_storage.dart';
import '../services/weather_service.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._service, this._storage);

  final WeatherService _service;
  final LocalStorage _storage;

  List<Location> _results = [];
  List<Location> _favorites = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  List<Location> get results => _results;
  List<Location> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _favorites = await _storage.loadFavorites();
    notifyListeners();
  }

  /// Request ke Geocoding API setiap kali user mencari kota
  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      _results = [];
      _hasSearched = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _service.searchLocations(q);
    } catch (e) {
      debugPrint('Error search: $e');
      _results = [];
      _errorMessage = 'Pencarian gagal. Periksa koneksi internet.';
    }

    _hasSearched = true;
    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(Location location) => _favorites.contains(location);

  Future<void> toggleFavorite(Location location) async {
    if (_favorites.contains(location)) {
      _favorites.remove(location);
    } else {
      _favorites.add(location);
    }
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }
}