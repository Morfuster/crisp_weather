import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/city.dart';
import '../../data/services/geocoding_service.dart';

class CitiesProvider extends ChangeNotifier {
  CitiesProvider({required GeocodingService geocodingService})
      : _geocodingService = geocodingService;

  final GeocodingService _geocodingService;

  List<City> _cities = [];
  City? _activeCity;
  bool _locationLoading = false;
  String? _locationError;

  List<City> get cities => List.unmodifiable(_cities);
  City? get activeCity => _activeCity;
  bool get locationLoading => _locationLoading;
  String? get locationError => _locationError;

  static const _prefsKey = 'saved_cities';
  static const _activeCityKey = 'active_city';

  Future<void> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _cities = raw
        .map((s) => City.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    final activeRaw = prefs.getString(_activeCityKey);
    if (activeRaw != null) {
      final activeJson = jsonDecode(activeRaw) as Map<String, dynamic>;
      _activeCity = City.fromJson(activeJson);
    } else if (_cities.isNotEmpty) {
      _activeCity = _cities.first;
    }
    notifyListeners();
  }

  Future<void> addCity(City city) async {
    final alreadyExists =
        _cities.any((c) => c.latitude == city.latitude && c.longitude == city.longitude);
    if (alreadyExists) return;

    _cities = [..._cities, city];
    _activeCity ??= city;
    await _persist();
    notifyListeners();
  }

  Future<void> removeCity(City city) async {
    _cities = _cities.where((c) => c != city).toList();
    if (_activeCity == city) {
      _activeCity = _cities.isNotEmpty ? _cities.first : null;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setActiveCity(City city) async {
    _activeCity = city;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeCityKey, jsonEncode(city.toJson()));
    notifyListeners();
  }

  Future<void> detectCurrentLocation() async {
    _locationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final results = await _geocodingService.searchCities(
        '${position.latitude},${position.longitude}',
      );

      City locationCity;
      if (results.isNotEmpty) {
        locationCity = results.first.copyWith(isCurrentLocation: true);
      } else {
        locationCity = City(
          name: 'My Location',
          country: '',
          latitude: position.latitude,
          longitude: position.longitude,
          timezone: 'auto',
          isCurrentLocation: true,
        );
      }

      _cities = [
        locationCity,
        ..._cities.where((c) => !c.isCurrentLocation),
      ];
      _activeCity = locationCity;
      await _persist();
    } catch (e) {
      _locationError = e.toString();
    } finally {
      _locationLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _cities.map((c) => jsonEncode(c.toJson())).toList(),
    );
    if (_activeCity != null) {
      await prefs.setString(_activeCityKey, jsonEncode(_activeCity!.toJson()));
    }
  }
}
