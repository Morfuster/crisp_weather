import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/weather_exception.dart';
import '../../core/models/city.dart';
import '../adapters/open_meteo_adapter.dart';

class GeocodingService {
  static const _baseUrl = 'geocoding-api.open-meteo.com';

  Future<List<City>> searchCities(String query) async {
    final uri = Uri.https(_baseUrl, '/v1/search', {
      'name': query,
      'count': '5',
      'language': 'en',
    });

    http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      response = await http.get(uri);
    }

    if (response.statusCode != 200) {
      throw GeocodingException(
        message: 'Failed to search cities for "$query"',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return parseCities(json);
  }
}
