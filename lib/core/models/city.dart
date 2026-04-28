class City {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.isCurrentLocation,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        name: json['name'] as String,
        country: json['country'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timezone: json['timezone'] as String? ?? 'auto',
        isCurrentLocation: json['isCurrentLocation'] as bool? ?? false,
      );

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;
  final bool isCurrentLocation;

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'isCurrentLocation': isCurrentLocation,
      };

  City copyWith({
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    String? timezone,
    bool? isCurrentLocation,
  }) =>
      City(
        name: name ?? this.name,
        country: country ?? this.country,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        timezone: timezone ?? this.timezone,
        isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => '$name, $country';
}
