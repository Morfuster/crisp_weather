class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
    required this.windDirectionDominant,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipitationSum;
  final int precipitationProbabilityMax;
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;
  final int windDirectionDominant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecast &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
