import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/weather_exception.dart';
import '../../core/models/city.dart';
import '../../core/models/weather_data.dart';
import '../adapters/open_meteo_adapter.dart';

class WeatherService {
  static const _baseUrl = 'api.open-meteo.com';
  static const _maxAttempts = 3;
  static const _retryDelays = [Duration(seconds: 2), Duration(seconds: 5)];

  Future<WeatherData> fetchWeather(City city) async {
    final uri = Uri.https(_baseUrl, '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': [
        'temperature_2m',
        'apparent_temperature',
        'relative_humidity_2m',
        'weather_code',
        'wind_speed_10m',
        'wind_direction_10m',
        'uv_index',
        'dew_point_2m',
        'surface_pressure',
        'visibility',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'weather_code',
        'precipitation',
        'snowfall',
        'precipitation_probability',
      ].join(','),
      'daily': [
        'temperature_2m_max',
        'temperature_2m_min',
        'weather_code',
        'precipitation_sum',
        'precipitation_probability_max',
        'sunrise',
        'sunset',
        'uv_index_max',
        'wind_direction_10m_dominant',
        'wind_speed_10m_max',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': '7',
    });

    Object? lastError;

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future.delayed(_retryDelays[attempt - 1]);
      }

      try {
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw WeatherException(
            message: 'Failed to fetch weather for ${city.name}',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return parseWeatherData(json, city);
      } on WeatherException {
        // HTTP errors are not retryable — surface immediately
        rethrow;
      } catch (e) {
        lastError = e;
      }
    }

    throw WeatherException(
      message: 'Network error fetching weather for ${city.name}: $lastError',
      statusCode: 0,
      responseBody: '',
    );
  }
}
