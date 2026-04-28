import 'city.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';

class WeatherData {
  const WeatherData({
    required this.city,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final City city;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
}
