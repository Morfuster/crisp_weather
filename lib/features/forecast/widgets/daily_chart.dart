import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class DailyChart extends StatelessWidget {
  const DailyChart({super.key, required this.daily});

  final List<DailyForecast> daily;

  static const _colWidth = 72.0;
  static const _dateRowH = 36.0;   // day name + date  ← NOW FIRST (top)
  static const _iconRowH = 38.0;   // weather icon     ← below date
  static const _curveH = 120.0;    // temp curves zone
  static const _barZoneH = 56.0;   // precip bars + value label

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final allTemps = daily.expand((d) => [d.tempMax, d.tempMin]).toList();
    final minTemp = allTemps.reduce(math.min);
    final maxTemp = allTemps.reduce(math.max);
    final tempRange = (maxTemp - minTemp).clamp(4.0, double.infinity);

    final maxPrecip = daily
        .map((d) => d.precipitationSum)
        .reduce(math.max)
        .clamp(0.1, double.infinity);

    final totalW = _colWidth * daily.length;
    const totalH = _iconRowH + _curveH + _barZoneH + _dateRowH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ForecastPanel(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            height: totalH,
            child: Stack(
              children: [
                // Curves + bars painted behind — starts after date + icon rows
                Positioned(
                  top: _dateRowH + _iconRowH,
                  left: 0,
                  right: 0,
                  height: _curveH + _barZoneH,
                  child: CustomPaint(
                    painter: _DailyChartPainter(
                      daily: daily,
                      minTemp: minTemp,
                      tempRange: tempRange,
                      maxPrecip: maxPrecip,
                      colWidth: _colWidth,
                      curveH: _curveH,
                      barZoneH: _barZoneH,
                    ),
                  ),
                ),
                // Per-column overlay: icon, temp labels, precip label, date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(daily.length, (i) {
                    final d = daily[i];
                    final maxNorm =
                        (d.tempMax - minTemp) / tempRange;
                    final minNorm =
                        (d.tempMin - minTemp) / tempRange;

                    final maxDotY = _dateRowH + _iconRowH +
                        _curveH * (1 - maxNorm) * 0.8 +
                        _curveH * 0.1;
                    final minDotY = _dateRowH + _iconRowH +
                        _curveH * (1 - minNorm) * 0.8 +
                        _curveH * 0.1;

                    final precip = d.precipitationSum;

                    return SizedBox(
                      width: _colWidth,
                      height: totalH + _dateRowH,
                      child: Stack(
                        children: [
                          // Day name + date — topmost row
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: _dateRowH,
                            child: Center(
                              child: Text(
                                _dateLabel(d.date, i),
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Weather icon — below the date row
                          Positioned(
                            top: _dateRowH + 2,
                            left: 0,
                            right: 0,
                            height: _iconRowH - 4,
                            child: Center(
                              child: WeatherIcon(
                                  code: d.weatherCode, size: 34),
                            ),
                          ),
                          // Max temp label — 14px above the dot
                          Positioned(
                            top: maxDotY - 20,
                            left: 0,
                            right: 0,
                            height: 14,
                            child: Center(
                              child: Text(
                                '${d.tempMax.round()}°',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          // Min temp label — 14px above the dot
                          Positioned(
                            top: minDotY - 20,
                            left: 0,
                            right: 0,
                            height: 14,
                            child: Center(
                              child: Text(
                                '${d.tempMin.round()}°',
                                style: const TextStyle(
                                  color: Color(0xFF64B5F6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          // Precip value above bar
                          if (precip > 0)
                            Positioned(
                              top: _dateRowH + _iconRowH + _curveH - 2,
                              left: 0,
                              right: 0,
                              height: 16,
                              child: Center(
                                child: Text(
                                  precip >= 10
                                      ? '${precip.round()}'
                                      : precip.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
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
        // Legend
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
          child: Row(
            children: const [
              _LegendItem(color: Color(0xFFFF6B6B), label: 'Max (°C)'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFF64B5F6), label: 'Min (°C)'),
              SizedBox(width: 16),
              _LegendItem(color: AppColors.accentBlue, label: 'Rain (mm)', isBar: true),
            ],
          ),
        ),
      ],
    );
  }

  String _dateLabel(DateTime date, int index) {
    if (index == 0) return 'Today\n${DateFormat('M/d').format(date)}';
    return '${DateFormat('EEE').format(date)}\n${DateFormat('M/d').format(date)}';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isBar = false,
  });

  final Color color;
  final String label;
  final bool isBar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isBar
            ? Container(
                width: 10,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withAlpha(160),
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : Container(
                width: 20,
                height: 2.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }
}

class _DailyChartPainter extends CustomPainter {
  const _DailyChartPainter({
    required this.daily,
    required this.minTemp,
    required this.tempRange,
    required this.maxPrecip,
    required this.colWidth,
    required this.curveH,
    required this.barZoneH,
  });

  final List<DailyForecast> daily;
  final double minTemp;
  final double tempRange;
  final double maxPrecip;
  final double colWidth;
  final double curveH;
  final double barZoneH;

  double _normTemp(double temp) =>
      ((temp - minTemp) / tempRange).clamp(0.0, 1.0);

  double _dotY(double temp) =>
      curveH * (1 - _normTemp(temp)) * 0.8 + curveH * 0.1;

  Offset _maxOffset(int i) =>
      Offset(colWidth * i + colWidth / 2, _dotY(daily[i].tempMax));

  Offset _minOffset(int i) =>
      Offset(colWidth * i + colWidth / 2, _dotY(daily[i].tempMin));

  @override
  void paint(Canvas canvas, Size size) {
    _drawCurve(
      canvas,
      points: List.generate(daily.length, _maxOffset),
      color: const Color(0xFFFF6B6B),
      fillTop: true,
    );
    _drawCurve(
      canvas,
      points: List.generate(daily.length, _minOffset),
      color: const Color(0xFF64B5F6),
      fillTop: false,
    );
    _drawPrecipBars(canvas);
  }

  void _drawCurve(Canvas canvas,
      {required List<Offset> points,
      required Color color,
      required bool fillTop}) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
          (points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset(
          (points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy,
          points[i + 1].dx, points[i + 1].dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 4,
          Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(p, 4,
          Paint()
            ..color = Colors.white.withAlpha(200)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }
  }

  void _drawPrecipBars(Canvas canvas) {
    const barMaxH = 36.0;
    final barPaint = Paint()
      ..color = AppColors.accentBlue.withAlpha(160)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < daily.length; i++) {
      final precip = daily[i].precipitationSum;
      if (precip <= 0) continue;

      final barH = (precip / maxPrecip * barMaxH).clamp(4.0, barMaxH);
      final x = colWidth * i + colWidth * 0.3;
      final barW = colWidth * 0.4;
      final top = curveH + (barZoneH - barH - 16); // leave 16px for label + bottom

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barW, barH),
          const Radius.circular(3),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DailyChartPainter old) =>
      old.daily != daily ||
      old.minTemp != minTemp ||
      old.tempRange != tempRange;
}
