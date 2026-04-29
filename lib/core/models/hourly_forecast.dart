class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitation,
    required this.snowfall,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double precipitation; // mm
  final double snowfall;      // cm
  final int precipitationProbability; // %

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyForecast &&
          runtimeType == other.runtimeType &&
          time == other.time;

  @override
  int get hashCode => time.hashCode;
}
