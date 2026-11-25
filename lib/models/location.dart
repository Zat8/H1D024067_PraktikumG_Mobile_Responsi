class Location {
  const Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1; // provinsi / wilayah

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String? ?? '-',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'admin1': admin1,
  };

  /// Teks wilayah, misalnya "Jawa Tengah, Indonesia"
  String get region =>
      [admin1, country].where((s) => s != null && s.isNotEmpty).join(', ');

  // Dipakai untuk membandingkan favorit (berdasarkan koordinat)
  @override
  bool operator ==(Object other) =>
      other is Location &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}