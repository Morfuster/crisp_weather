import '../../core/models/city.dart';
import '../../core/models/current_weather.dart';
import '../../core/models/daily_forecast.dart';
import '../../core/models/hourly_forecast.dart';
import '../../core/models/weather_data.dart';

const Map<int, String> wmoLabels = {
  0: 'Clear sky',
  1: 'Mainly clear',
  2: 'Partly cloudy',
  3: 'Overcast',
  45: 'Foggy',
  48: 'Rime fog',
  51: 'Light drizzle',
  53: 'Drizzle',
  55: 'Heavy drizzle',
  56: 'Light freezing drizzle',
  57: 'Heavy freezing drizzle',
  61: 'Slight rain',
  63: 'Moderate rain',
  65: 'Heavy rain',
  66: 'Light freezing rain',
  67: 'Heavy freezing rain',
  71: 'Slight snow',
  73: 'Moderate snow',
  75: 'Heavy snow',
  77: 'Snow grains',
  80: 'Slight showers',
  81: 'Moderate showers',
  82: 'Violent showers',
  85: 'Slight snow showers',
  86: 'Heavy snow showers',
  95: 'Thunderstorm',
  96: 'Thunderstorm with hail',
  99: 'Thunderstorm with heavy hail',
};

String wmoLabel(int code) => wmoLabels[code] ?? 'Unknown';

WeatherData parseWeatherData(Map<String, dynamic> json, City city) {
  final currentJson = json['current'] as Map<String, dynamic>;
  final current = CurrentWeather.fromJson(currentJson);

  final hourlyJson = json['hourly'] as Map<String, dynamic>;
  final times = hourlyJson['time'] as List<dynamic>;
  final temps = hourlyJson['temperature_2m'] as List<dynamic>;
  final codes = hourlyJson['weather_code'] as List<dynamic>;

  final now = DateTime.now();
  final hourly = <HourlyForecast>[];
  for (var i = 0; i < times.length && hourly.length < 24; i++) {
    final t = DateTime.parse(times[i] as String);
    if (t.isAfter(now.subtract(const Duration(minutes: 30)))) {
      hourly.add(HourlyForecast(
        time: t,
        temperature: (temps[i] as num).toDouble(),
        weatherCode: (codes[i] as num).toInt(),
      ));
    }
  }

  final dailyJson = json['daily'] as Map<String, dynamic>;
  final dTimes = dailyJson['time'] as List<dynamic>;
  final dMax = dailyJson['temperature_2m_max'] as List<dynamic>;
  final dMin = dailyJson['temperature_2m_min'] as List<dynamic>;
  final dCodes = dailyJson['weather_code'] as List<dynamic>;
  final dPrecip = dailyJson['precipitation_sum'] as List<dynamic>;

  final daily = List<DailyForecast>.generate(
    dTimes.length,
    (i) => DailyForecast(
      date: DateTime.parse(dTimes[i] as String),
      tempMax: (dMax[i] as num).toDouble(),
      tempMin: (dMin[i] as num).toDouble(),
      weatherCode: (dCodes[i] as num).toInt(),
      precipitationSum: (dPrecip[i] as num? ?? 0).toDouble(),
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
