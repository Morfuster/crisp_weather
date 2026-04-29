import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/hourly_forecast.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class HourlyScroll extends StatelessWidget {
  const HourlyScroll({super.key, required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hourly.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _HourlyItem(entry: hourly[index]),
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  const _HourlyItem({required this.entry});

  final HourlyForecast entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = DateFormat('h a').format(entry.time).toLowerCase();
    return ForecastPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 14,
      pressable: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(timeLabel, style: theme.textTheme.bodySmall),
          WeatherIcon(code: entry.weatherCode, size: 30),
          Text(
            '${entry.temperature.round()}°',
            style: theme.textTheme.bodyLarge,
          ),
          if (entry.precipitationProbability > 0)
            Text(
              '${entry.precipitationProbability}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64B5F6),
                fontSize: 10,
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
