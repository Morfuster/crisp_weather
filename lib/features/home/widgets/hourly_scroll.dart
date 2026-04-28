import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/hourly_forecast.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/weather_icon.dart';

class HourlyScroll extends StatelessWidget {
  const HourlyScroll({super.key, required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
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
    final timeLabel = DateFormat('HH:mm').format(entry.time);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(timeLabel, style: theme.textTheme.bodySmall),
          WeatherIcon(code: entry.weatherCode, size: 24),
          Text(
            '${entry.temperature.round()}°',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
