import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../data/adapters/open_meteo_adapter.dart';
import '../../../shared/widgets/weather_icon.dart';

class DailyRow extends StatelessWidget {
  const DailyRow({super.key, required this.forecast});

  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = DateFormat('EEE, MMM d').format(forecast.date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(dayLabel, style: theme.textTheme.bodyMedium),
          ),
          WeatherIcon(code: forecast.weatherCode, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              wmoLabel(forecast.weatherCode),
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (forecast.precipitationSum > 0)
            Row(
              children: [
                Icon(Icons.water_drop_rounded,
                    size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationSum.toStringAsFixed(1)} mm',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
              ],
            ),
          Text(
            '${forecast.tempMax.round()}° / ${forecast.tempMin.round()}°',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
