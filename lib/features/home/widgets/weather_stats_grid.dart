import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/current_weather.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';

class WeatherStatsGrid extends StatelessWidget {
  const WeatherStatsGrid({super.key, required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _UvIndexTile(uvIndex: weather.uvIndex)),
                const SizedBox(width: 12),
                Expanded(
                  child: _WindCompassTile(
                    speed: weather.windSpeed,
                    direction: weather.windDirection,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SimpleTile(
                    icon: Icons.thermostat_rounded,
                    title: 'dewPoint'.tr(),
                    value: '${weather.dewPoint.round()}°',
                    subtitle: 'dewPointDesc'.tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimpleTile(
                    icon: Icons.speed_rounded,
                    title: 'pressure'.tr(),
                    value: '${weather.pressure.round()} hPa',
                    subtitle: '',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SimpleTile(
                    icon: Icons.visibility_rounded,
                    title: 'visibility'.tr(),
                    value: _formatVisibility(weather.visibility),
                    subtitle: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimpleTile(
                    icon: Icons.water_drop_outlined,
                    title: 'humidity'.tr(),
                    value: '${weather.humidity}%',
                    subtitle: '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVisibility(double metres) {
    if (metres >= 1000) {
      return '${(metres / 1000).toStringAsFixed(1)} km';
    }
    return '${metres.round()} m';
  }
}

// ── UV Index tile with gradient bar ──────────────────────────────────────────

class _UvIndexTile extends StatelessWidget {
  const _UvIndexTile({required this.uvIndex});

  final double uvIndex;

  String get _label {
    if (uvIndex < 3) return 'uvLow'.tr();
    if (uvIndex < 6) return 'uvModerate'.tr();
    if (uvIndex < 8) return 'uvHigh'.tr();
    if (uvIndex < 11) return 'uvVeryHigh'.tr();
    return 'uvExtreme'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedUv = uvIndex.clamp(0.0, 11.0);
    final fraction = clampedUv / 11.0;

    return ForecastPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'uvIndex'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            uvIndex.toStringAsFixed(1),
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            _label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFFFFEB3B),
                          Color(0xFFFF9800),
                          Color(0xFFF44336),
                          Color(0xFF9C27B0),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-1 + fraction * 2, 0),
                    child: Container(
                      width: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wind compass tile ─────────────────────────────────────────────────────────

class _WindCompassTile extends StatelessWidget {
  const _WindCompassTile({required this.speed, required this.direction});

  final double speed;
  final int direction;

  String _bearingLabel(int deg) {
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return labels[((deg + 22) % 360) ~/ 45];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForecastPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air_rounded, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'wind'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${speed.round()} ${'kmh'.tr()}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text(
                      _bearingLabel(direction),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: CustomPaint(
                  painter: _CompassPainter(degrees: direction.toDouble()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({required this.degrees});

  final double degrees;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;

    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Arrow pointing FROM wind origin (wind_direction_10m = direction wind comes FROM)
    // arrow tip points to where wind is going (opposite of origin)
    final radians = (degrees - 90) * math.pi / 180;
    final arrowTip = Offset(
      cx + r * 0.75 * math.cos(radians),
      cy + r * 0.75 * math.sin(radians),
    );
    final arrowTail = Offset(
      cx - r * 0.55 * math.cos(radians),
      cy - r * 0.55 * math.sin(radians),
    );

    canvas.drawLine(
      arrowTail,
      arrowTip,
      Paint()
        ..color = AppColors.accentBlue
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Arrow head
    final headAngle = math.pi / 6;
    final headLen = r * 0.3;
    for (final side in [-1, 1]) {
      final headPoint = Offset(
        arrowTip.dx +
            headLen *
                math.cos(radians + math.pi + side * headAngle),
        arrowTip.dy +
            headLen *
                math.sin(radians + math.pi + side * headAngle),
      );
      canvas.drawLine(
        arrowTip,
        headPoint,
        Paint()
          ..color = AppColors.accentBlue
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      2.5,
      Paint()..color = Colors.white38,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.degrees != degrees;
}

// ── Simple stat tile ──────────────────────────────────────────────────────────

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForecastPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineMedium),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}
