class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperature: (json['temperature_2m'] as num).toDouble(),
        feelsLike: (json['apparent_temperature'] as num).toDouble(),
        humidity: (json['relative_humidity_2m'] as num).toInt(),
        windSpeed: (json['wind_speed_10m'] as num).toDouble(),
        weatherCode: (json['weather_code'] as num).toInt(),
        time: DateTime.parse(json['time'] as String),
      );

  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime time;

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
