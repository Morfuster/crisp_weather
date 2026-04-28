import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/current_weather.dart';
import '../../../data/adapters/open_meteo_adapter.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({super.key, required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ForecastPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°',
                        style: theme.textTheme.displayLarge,
                      ),
                      Text(
                        wmoLabel(weather.weatherCode),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'feelsLike'.tr(args: ['${weather.feelsLike.round()}']),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                WeatherIcon(code: weather.weatherCode, size: 80),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  icon: Icons.water_drop_outlined,
                  label: '${weather.humidity}%',
                  sublabel: 'humidity'.tr(),
                ),
                _Stat(
                  icon: Icons.air_rounded,
                  label: '${weather.windSpeed.round()} ${'kmh'.tr()}',
                  sublabel: 'wind'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(sublabel, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
