import '../../core/models/city.dart';
import '../../core/models/current_weather.dart';
import '../../core/models/daily_forecast.dart';
import '../../core/models/hourly_forecast.dart';
import '../../core/models/weather_data.dart';

WeatherData parseWeatherData(Map<String, dynamic> json, City city) {
  final currentJson = json['current'] as Map<String, dynamic>;
  final current = CurrentWeather.fromJson(currentJson);

  final hourlyJson = json['hourly'] as Map<String, dynamic>;
  final times = hourlyJson['time'] as List<dynamic>;
  final temps = hourlyJson['temperature_2m'] as List<dynamic>;
  final codes = hourlyJson['weather_code'] as List<dynamic>;
  final precips = hourlyJson['precipitation'] as List<dynamic>;
  final snowfalls = hourlyJson['snowfall'] as List<dynamic>;
  final precipProbs = hourlyJson['precipitation_probability'] as List<dynamic>;

  final now = DateTime.now();
  final hourly = <HourlyForecast>[];
  for (var i = 0; i < times.length && hourly.length < 24; i++) {
    final t = DateTime.parse(times[i] as String);
    if (t.isAfter(now.subtract(const Duration(minutes: 30)))) {
      hourly.add(HourlyForecast(
        time: t,
        temperature: (temps[i] as num).toDouble(),
        weatherCode: (codes[i] as num).toInt(),
        precipitation: (precips[i] as num? ?? 0).toDouble(),
        snowfall: (snowfalls[i] as num? ?? 0).toDouble(),
        precipitationProbability: (precipProbs[i] as num? ?? 0).toInt(),
      ));
    }
  }

  final dailyJson = json['daily'] as Map<String, dynamic>;
  final dTimes = dailyJson['time'] as List<dynamic>;
  final dMax = dailyJson['temperature_2m_max'] as List<dynamic>;
  final dMin = dailyJson['temperature_2m_min'] as List<dynamic>;
  final dCodes = dailyJson['weather_code'] as List<dynamic>;
  final dPrecip = dailyJson['precipitation_sum'] as List<dynamic>;
  final dPrecipProb = dailyJson['precipitation_probability_max'] as List<dynamic>;
  final dSunrise = dailyJson['sunrise'] as List<dynamic>;
  final dSunset = dailyJson['sunset'] as List<dynamic>;
  final dUvMax = dailyJson['uv_index_max'] as List<dynamic>;
  final dWindDir = dailyJson['wind_direction_10m_dominant'] as List<dynamic>;

  final daily = List<DailyForecast>.generate(
    dTimes.length,
    (i) => DailyForecast(
      date: DateTime.parse(dTimes[i] as String),
      tempMax: (dMax[i] as num).toDouble(),
      tempMin: (dMin[i] as num).toDouble(),
      weatherCode: (dCodes[i] as num).toInt(),
      precipitationSum: (dPrecip[i] as num? ?? 0).toDouble(),
      precipitationProbabilityMax: (dPrecipProb[i] as num? ?? 0).toInt(),
      sunrise: DateTime.parse(dSunrise[i] as String),
      sunset: DateTime.parse(dSunset[i] as String),
      uvIndexMax: (dUvMax[i] as num? ?? 0).toDouble(),
      windDirectionDominant: (dWindDir[i] as num? ?? 0).toInt(),
    ),
  );

  return WeatherData(city: city, current: current, hourly: hourly, daily: daily);
}

List<City> parseCities(Map<String, dynamic> json) {
  final results = json['results'] as List<dynamic>? ?? [];
  return results.map((e) {
    final m = e as Map<String, dynamic>;
    return City(
      name: m['name'] as String,
      country: m['country'] as String? ?? '',
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      timezone: m['timezone'] as String? ?? 'auto',
      isCurrentLocation: false,
    );
  }).toList();
}
