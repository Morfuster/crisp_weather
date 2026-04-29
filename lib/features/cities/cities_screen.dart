import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/city.dart';
import '../../data/services/geocoding_service.dart';
import '../../shared/theme/app_colors.dart';
import 'cities_provider.dart';
import 'widgets/city_search_bar.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  List<City> _searchResults = [];
  bool _searching = false;
  String? _searchError;

  Future<void> _onSearch(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final service = GeocodingService();
      final results = await service.searchCities(query.trim());
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = '${'searchFailed'.tr()}: ${e.toString()}';
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesProvider = context.watch<CitiesProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('tabCities'.tr(), style: theme.textTheme.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CitySearchBar(onSearch: _onSearch),
            ),
            if (_searching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_searchError!, style: theme.textTheme.bodySmall),
              )
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: _SearchResults(
                  results: _searchResults,
                  onAdd: (city) {
                    context.read<CitiesProvider>().addCity(city);
                    setState(() => _searchResults = []);
                  },
                ),
              )
            else
              Expanded(
                child: _SavedCitiesList(
                  cities: citiesProvider.cities,
                  activeCity: citiesProvider.activeCity,
                  locationLoading: citiesProvider.locationLoading,
                  onSelect: (city) =>
                      context.read<CitiesProvider>().setActiveCity(city),
                  onRemove: (city) =>
                      context.read<CitiesProvider>().removeCity(city),
                  onDetectLocation: () =>
                      context.read<CitiesProvider>().detectCurrentLocation(),
                ),
              ),
            const _AttributionFooter(),
          ],
        ),
      ),
    );
  }
}

class _AttributionFooter extends StatelessWidget {
  const _AttributionFooter();

  static final _url = Uri.parse('https://open-meteo.com');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_outlined, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              children: [
                TextSpan(text: '${'weatherData'.tr()} '),
                TextSpan(
                  text: 'Open-Meteo.com',
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.accentBlue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launchUrl(_url, mode: LaunchMode.externalApplication),
                ),
                TextSpan(text: ' — ${'freeOpenSource'.tr()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onAdd});

  final List<City> results;
  final ValueChanged<City> onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, index) {
        final city = results[index];
        return ListTile(
          leading: const Icon(Icons.location_city_rounded,
              color: AppColors.textSecondary),
          title: Text(city.name,
              style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(city.country,
              style: Theme.of(context).textTheme.bodySmall),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_rounded,
                color: AppColors.accentBlue),
            onPressed: () => onAdd(city),
          ),
          onTap: () => onAdd(city),
        );
      },
    );
  }
}

class _SavedCitiesList extends StatelessWidget {
  const _SavedCitiesList({
    required this.cities,
    required this.activeCity,
    required this.locationLoading,
    required this.onSelect,
    required this.onRemove,
    required this.onDetectLocation,
  });

  final List<City> cities;
  final City? activeCity;
  final bool locationLoading;
  final ValueChanged<City> onSelect;
  final ValueChanged<City> onRemove;
  final VoidCallback onDetectLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: locationLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded,
                  color: AppColors.accentBlue),
          title: Text('useMyLocation'.tr(), style: theme.textTheme.bodyLarge),
          onTap: locationLoading ? null : onDetectLocation,
        ),
        const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
        Expanded(
          child: cities.isEmpty
              ? Center(
                  child: Text(
                    'noCitiesYet'.tr(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (_, index) {
                    final city = cities[index];
                    final isActive = city == activeCity;
                    return Dismissible(
                      key: ValueKey('${city.latitude}_${city.longitude}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.red.withAlpha(51),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.red),
                      ),
                      onDismissed: (_) => onRemove(city),
                      child: ListTile(
                        leading: Icon(
                          city.isCurrentLocation
                              ? Icons.my_location_rounded
                              : Icons.location_on_rounded,
                          color: isActive
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                        ),
                        title: Text(city.name, style: theme.textTheme.bodyLarge),
                        subtitle: Text(city.country,
                            style: theme.textTheme.bodySmall),
                        trailing: isActive
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.accentBlue)
                            : null,
                        onTap: () => onSelect(city),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
