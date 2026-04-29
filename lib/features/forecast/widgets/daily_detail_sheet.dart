import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../core/models/hourly_forecast.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

void showDailyDetail(
  BuildContext context, {
  required DailyForecast day,
  required List<HourlyForecast> allHourly,
}) {
  // Filter hourly entries that belong to this day
  final dayHourly = allHourly.where((h) {
    return h.time.year == day.date.year &&
        h.time.month == day.date.month &&
        h.time.day == day.date.day;
  }).toList();

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A2744),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DailyDetailSheet(day: day, hourly: dayHourly),
  );
}

class DailyDetailSheet extends StatelessWidget {
  const DailyDetailSheet({
    super.key,
    required this.day,
    required this.hourly,
  });

  final DailyForecast day;
  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final screenH = MediaQuery.of(context).size.height;
    final dateLabel = DateFormat('EEEE, MMMM d').format(day.date);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Day header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  WeatherIcon(code: day.weatherCode, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            )),
                        Text(
                          'wmo${day.weatherCode}'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        settings.tempUnit.format(day.tempMax),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        settings.tempUnit.format(day.tempMin),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Summary stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatChip(
                    icon: Icons.water_drop_rounded,
                    label: '${day.precipitationProbabilityMax}%',
                    color: AppColors.accentBlue,
                  ),
                  if (day.precipitationSum > 0)
                    _StatChip(
                      icon: Icons.umbrella_rounded,
                      label: day.precipitationSum >= 10
                          ? '${day.precipitationSum.round()}mm'
                          : '${day.precipitationSum.toStringAsFixed(1)}mm',
                      color: AppColors.accentBlue,
                    ),
                  _StatChip(
                    icon: Icons.wb_sunny_outlined,
                    label: 'UV ${day.uvIndexMax.toStringAsFixed(1)}',
                    color: _uvColor(day.uvIndexMax),
                  ),
                  _StatChip(
                    icon: Icons.air_rounded,
                    label: settings.windUnit.format(day.windSpeedMax),
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Divider(color: Colors.white12, height: 1),
            ),
            const SizedBox(height: 12),
            // Hourly list
            Expanded(
              child: hourly.isEmpty
                  ? Center(
                      child: Text(
                        'noForecastData'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: hourly.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _HourlyRow(entry: hourly[i], settings: settings),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _uvColor(double uv) {
    if (uv < 3) return AppColors.accentGreen;
    if (uv < 6) return AppColors.accentYellow;
    if (uv < 8) return AppColors.accentOrange;
    if (uv < 11) return AppColors.accentRed;
    return const Color(0xFF9C27B0);
  }
}

class _HourlyRow extends StatelessWidget {
  const _HourlyRow({required this.entry, required this.settings});

  final HourlyForecast entry;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = DateFormat('h a').format(entry.time).toLowerCase();
    final total = entry.precipitation + entry.snowfall;

    return ForecastPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                )),
          ),
          WeatherIcon(code: entry.weatherCode, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'wmo${entry.weatherCode}'.tr(),
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (entry.precipitationProbability > 0) ...[
            Text(
              '${entry.precipitationProbability}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accentBlue,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (total > 0) ...[
            Text(
              entry.snowfall > entry.precipitation
                  ? '${entry.snowfall.toStringAsFixed(1)}cm'
                  : '${entry.precipitation.toStringAsFixed(1)}mm',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accentBlue.withAlpha(180),
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            settings.tempUnit.format(entry.temperature),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
