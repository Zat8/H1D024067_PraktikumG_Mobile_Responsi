import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/search_view_model.dart';
import '../viewmodels/weather_view_model.dart';

const _bgTop = Color(0xFF2B2468);
const _bgBottom = Color(0xFF7B5CE0);
const _glass = Color(0x26FFFFFF);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _choose(Location location) async {
    final weatherVm = context.read<WeatherViewModel>();
    final navigator = Navigator.of(context);
    await weatherVm.selectLocation(location);
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

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
          title: const Text('Cari Lokasi'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom pencarian
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Nama kota, contoh: Purwokerto',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _controller.clear();
                        vm.search('');
                      },
                    ),
                    filled: true,
                    fillColor: _glass,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                  ),
                  onSubmitted: (q) => vm.search(q),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildBody(vm)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    // Belum mencari -> tampilkan favorit
    if (!vm.hasSearched) {
      return _buildFavorites(vm);
    }

    if (vm.results.isEmpty) {
      return const Center(
        child: Text(
          'Kota tidak ditemukan. Coba nama lain.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: vm.results.length,
      itemBuilder: (_, i) => _buildTile(vm, vm.results[i]),
    );
  }

  Widget _buildFavorites(SearchViewModel vm) {
    if (vm.favorites.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada lokasi favorit.\nCari kota lalu tekan ikon bintang.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Favorit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...vm.favorites.map((l) => _buildTile(vm, l)),
      ],
    );
  }

  Widget _buildTile(SearchViewModel vm, Location location) {
    final isFav = vm.isFavorite(location);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: ListTile(
        onTap: () => _choose(location),
        leading: const Icon(Icons.location_on, color: Colors.white),
        title: Text(
          location.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          location.region,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: Icon(
            isFav ? Icons.star : Icons.star_border,
            color: isFav ? const Color(0xFFFFC857) : Colors.white,
          ),
          onPressed: () => vm.toggleFavorite(location),
        ),
      ),
    );
  }
}