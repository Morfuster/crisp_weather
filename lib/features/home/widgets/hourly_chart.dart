import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/hourly_forecast.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class HourlyChart extends StatelessWidget {
  const HourlyChart({super.key, required this.hourly});

  final List<HourlyForecast> hourly;

  static const _columnWidth = 56.0;
  static const _chartHeight = 80.0;
  static const _precipBarMaxHeight = 36.0;
  static const _topRowHeight = 56.0;  // icon + time
  static const _bottomRowHeight = 40.0; // precip bar + label

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final temps = hourly.map((h) => h.temperature).toList();
    final minTemp = temps.reduce(math.min);
    final maxTemp = temps.reduce(math.max);
    final tempRange = (maxTemp - minTemp).clamp(2.0, double.infinity);

    final maxPrecip = hourly
        .map((h) => h.precipitation + h.snowfall)
        .reduce(math.max)
        .clamp(0.1, double.infinity);

    final totalWidth = _columnWidth * hourly.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ForecastPanel(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
      height: _topRowHeight + _chartHeight + _bottomRowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Stack(
            children: [
              // Temperature curve + precip bars painted together
              Positioned.fill(
                top: _topRowHeight,
                bottom: _bottomRowHeight,
                child: CustomPaint(
                  painter: _HourlyChartPainter(
                    hourly: hourly,
                    minTemp: minTemp,
                    tempRange: tempRange,
                    maxPrecip: maxPrecip,
                    columnWidth: _columnWidth,
                    chartHeight: _chartHeight,
                    precipBarMaxHeight: _precipBarMaxHeight,
                  ),
                ),
              ),
              // Per-column overlays: time, icon, temp label, precip label
              Row(
                children: List.generate(hourly.length, (i) {
                  final h = hourly[i];
                  final total = h.precipitation + h.snowfall;
                  final isSnow = h.snowfall > h.precipitation;
                  final timeLabel = DateFormat('HH:mm').format(h.time);

                  // Normalized temp position (0 = bottom, 1 = top)
                  final norm =
                      (h.temperature - minTemp) / tempRange;
                  // Vertical center of the dot in chart space
                  final dotY = _topRowHeight +
                      _chartHeight * (1 - norm) * 0.7 +
                      _chartHeight * 0.15;

                  return SizedBox(
                    width: _columnWidth,
                    height: _topRowHeight + _chartHeight + _bottomRowHeight,
                    child: Stack(
                      children: [
                        // Time label at top
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 18,
                          child: Center(
                            child: Text(
                              timeLabel,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        // Weather icon
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          height: 24,
                          child: Center(
                            child: WeatherIcon(
                                code: h.weatherCode, size: 22),
                          ),
                        ),
                        // Temperature label above the dot
                        Positioned(
                          top: dotY - 22,
                          left: 0,
                          right: 0,
                          height: 16,
                          child: Center(
                            child: Text(
                              '${h.temperature.round()}°',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Precip label just above the bar top
                        if (total > 0)
                          Positioned(
                            bottom: (total / maxPrecip * _precipBarMaxHeight)
                                .clamp(2.0, _precipBarMaxHeight),
                            left: 0,
                            right: 0,
                            height: 14,
                            child: Center(
                              child: Text(
                                isSnow
                                    ? '${h.snowfall.toStringAsFixed(1)}cm'
                                    : '${h.precipitation.toStringAsFixed(1)}mm',
                                style: TextStyle(
                                  color: isSnow
                                      ? Colors.white70
                                      : AppColors.accentBlue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
          ),
        ),
      ),
    );
  }
}

class _HourlyChartPainter extends CustomPainter {
  const _HourlyChartPainter({
    required this.hourly,
    required this.minTemp,
    required this.tempRange,
    required this.maxPrecip,
    required this.columnWidth,
    required this.chartHeight,
    required this.precipBarMaxHeight,
  });

  final List<HourlyForecast> hourly;
  final double minTemp;
  final double tempRange;
  final double maxPrecip;
  final double columnWidth;
  final double chartHeight;
  final double precipBarMaxHeight;

  double _normTemp(double temp) =>
      ((temp - minTemp) / tempRange).clamp(0.0, 1.0);

  // y=0 is top of chart area
  double _dotY(double temp) =>
      chartHeight * (1 - _normTemp(temp)) * 0.7 + chartHeight * 0.15;

  Offset _dotOffset(int i) => Offset(
        columnWidth * i + columnWidth / 2,
        _dotY(hourly[i].temperature),
      );

  @override
  void paint(Canvas canvas, Size size) {
    _drawPrecipBars(canvas, size);
    _drawTempCurve(canvas);
    _drawDots(canvas);
  }

  void _drawPrecipBars(Canvas canvas, Size size) {
    for (var i = 0; i < hourly.length; i++) {
      final h = hourly[i];
      final total = h.precipitation + h.snowfall;
      if (total <= 0) continue;

      final barHeight =
          (total / maxPrecip * precipBarMaxHeight).clamp(2.0, precipBarMaxHeight);
      final isSnow = h.snowfall > h.precipitation;
      final barColor =
          isSnow ? const Color(0xFF90A4B8).withAlpha(160) : AppColors.accentBlue.withAlpha(120);
      final x = columnWidth * i + columnWidth * 0.25;
      final barWidth = columnWidth * 0.5;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = barColor);
    }
  }

  void _drawTempCurve(Canvas canvas) {
    if (hourly.length < 2) return;

    final path = Path();
    final fillPath = Path();

    final points = List.generate(hourly.length, _dotOffset);

    // Build smooth cubic bezier path
    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, chartHeight);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i].dy,
      );
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }

    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    // Gradient fill under the curve
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentBlue.withAlpha(80),
          AppColors.accentBlue.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, columnWidth * hourly.length, chartHeight));
    canvas.drawPath(fillPath, fillPaint);

    // Curve line
    final linePaint = Paint()
      ..color = AppColors.accentBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  void _drawDots(Canvas canvas) {
    final dotPaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < hourly.length; i++) {
      final offset = _dotOffset(i);
      canvas.drawCircle(offset, 4, dotPaint);
      canvas.drawCircle(offset, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(_HourlyChartPainter old) =>
      old.hourly != hourly ||
      old.minTemp != minTemp ||
      old.tempRange != tempRange;
}
