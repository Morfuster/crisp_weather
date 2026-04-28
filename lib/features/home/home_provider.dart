import 'package:flutter/foundation.dart';

import '../../core/errors/weather_exception.dart';
import '../../core/models/weather_data.dart';
import '../../data/services/weather_service.dart';
import '../cities/cities_provider.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required CitiesProvider citiesProvider,
    required WeatherService weatherService,
  })  : _citiesProvider = citiesProvider,
        _weatherService = weatherService {
    _citiesProvider.addListener(_onCityChanged);
  }

  final CitiesProvider _citiesProvider;
  final WeatherService _weatherService;

  WeatherData? _data;
  bool _loading = false;
  WeatherException? _error;

  WeatherData? get data => _data;
  bool get loading => _loading;
  WeatherException? get error => _error;

  void _onCityChanged() {
    if (_citiesProvider.activeCity != null) {
      refresh();
    }
  }

  Future<void> refresh() async {
    final city = _citiesProvider.activeCity;
    if (city == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _weatherService.fetchWeather(city);
    } on WeatherException catch (e) {
      _error = e;
    } catch (e) {
      _error = WeatherException(
        message: e.toString(),
        statusCode: 0,
        responseBody: '',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _citiesProvider.removeListener(_onCityChanged);
    super.dispose();
  }
}
