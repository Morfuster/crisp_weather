import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/weather_icon.dart';

class DailyRow extends StatelessWidget {
  const DailyRow({super.key, required this.forecast});

  final DailyForecast forecast;

  String _bearingLabel(int deg) {
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return labels[((deg + 22) % 360) ~/ 45];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final dayLabel = DateFormat('EEE, MMM d').format(forecast.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // — Main row: day / icon / condition / temps —
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(dayLabel, style: theme.textTheme.bodyMedium),
              ),
              WeatherIcon(code: forecast.weatherCode, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'wmo${forecast.weatherCode}'.tr(),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${settings.tempUnit.format(forecast.tempMax)} / ${settings.tempUnit.format(forecast.tempMin)}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // — Stats strip: precip / UV / wind —
          Row(
            children: [
              const SizedBox(width: 108),
              if (forecast.precipitationProbabilityMax > 0) ...[
                _StatChip(
                  icon: Icons.water_drop_rounded,
                  label: '${forecast.precipitationProbabilityMax}%',
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: 10),
              ],
              if (forecast.uvIndexMax > 0) ...[
                _StatChip(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV ${forecast.uvIndexMax.toStringAsFixed(1)}',
                  color: _uvColor(forecast.uvIndexMax),
                ),
                const SizedBox(width: 10),
              ],
              _StatChip(
                icon: Icons.navigation_rounded,
                label: _bearingLabel(forecast.windDirectionDominant),
                color: Colors.white54,
                iconAngle: forecast.windDirectionDominant * 3.14159 / 180,
              ),
            ],
          ),
        ],
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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    this.iconAngle,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double? iconAngle;

  @override
  Widget build(BuildContext context) {
    final iconWidget = iconAngle != null
        ? Transform.rotate(
            angle: iconAngle!,
            child: Icon(icon, size: 11, color: color),
          )
        : Icon(icon, size: 11, color: color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
