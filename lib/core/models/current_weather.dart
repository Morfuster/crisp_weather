class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.time,
    required this.uvIndex,
    required this.dewPoint,
    required this.pressure,
    required this.visibility,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperature: (json['temperature_2m'] as num).toDouble(),
        feelsLike: (json['apparent_temperature'] as num).toDouble(),
        humidity: (json['relative_humidity_2m'] as num).toInt(),
        windSpeed: (json['wind_speed_10m'] as num).toDouble(),
        windDirection: (json['wind_direction_10m'] as num).toInt(),
        weatherCode: (json['weather_code'] as num).toInt(),
        time: DateTime.parse(json['time'] as String),
        uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
        dewPoint: (json['dew_point_2m'] as num?)?.toDouble() ?? 0.0,
        pressure: (json['surface_pressure'] as num?)?.toDouble() ?? 0.0,
        visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      );

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final int weatherCode;
  final DateTime time;
  final double uvIndex;
  final double dewPoint;
  final double pressure;
  final double visibility; // metres

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentWeather &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          temperature == other.temperature;

  @override
  int get hashCode => Object.hash(time, temperature);
}
