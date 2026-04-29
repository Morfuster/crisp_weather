import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/weather_exception.dart';
import '../../core/models/city.dart';
import '../../core/models/weather_data.dart';
import '../adapters/open_meteo_adapter.dart';

class WeatherService {
  static const _baseUrl = 'api.open-meteo.com';

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

    http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      response = await http.get(uri);
    }

    if (response.statusCode != 200) {
      throw WeatherException(
        message: 'Failed to fetch weather for ${city.name}',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return parseWeatherData(json, city);
  }
}
