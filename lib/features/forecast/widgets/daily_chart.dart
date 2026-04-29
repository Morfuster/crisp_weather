import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class DailyChart extends StatelessWidget {
  const DailyChart({super.key, required this.daily});

  final List<DailyForecast> daily;

  static const _colWidth = 72.0;
  static const _dateRowH = 36.0;
  static const _iconRowH = 38.0;
  static const _curveH = 120.0;
  static const _barZoneH = 72.0; // enlarged: wind row + precip bar + label

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final settings = context.read<SettingsProvider>();
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
                      // Curves + bars painted behind
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
                      // Per-column overlay
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(daily.length, (i) {
                          final d = daily[i];
                          final todayLabel = 'today'.tr();
                          final maxNorm = (d.tempMax - minTemp) / tempRange;
                          final minNorm = (d.tempMin - minTemp) / tempRange;

                          // dot Y within the full column (absolute from top)
                          final maxDotY = _dateRowH + _iconRowH +
                              _curveH * (1 - maxNorm) * 0.8 +
                              _curveH * 0.1;
                          final minDotY = _dateRowH + _iconRowH +
                              _curveH * (1 - minNorm) * 0.8 +
                              _curveH * 0.1;

                          final precip = d.precipitationSum;

                          // wind: direction bearing label + speed
                          final windBearing = _bearingLabel(d.windDirectionDominant);
                          final windLabel = '${settings.windUnit.format(d.windSpeedMax)} $windBearing';

                          return SizedBox(
                            width: _colWidth,
                            height: totalH,
                            child: Stack(
                              children: [
                                // Date row
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: _dateRowH,
                                  child: Center(
                                    child: Text(
                                      _dateLabel(d.date, i, todayLabel),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Weather icon
                                Positioned(
                                  top: _dateRowH + 2,
                                  left: 0,
                                  right: 0,
                                  height: _iconRowH - 4,
                                  child: Center(
                                    child: WeatherIcon(code: d.weatherCode, size: 34),
                                  ),
                                ),
                                // Max temp label — below the dot
                                Positioned(
                                  top: maxDotY + 6,
                                  left: 0,
                                  right: 0,
                                  height: 14,
                                  child: Center(
                                    child: Text(
                                      settings.tempUnit.format(d.tempMax),
                                      style: const TextStyle(
                                        color: Color(0xFFFF6B6B),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                // Min temp label — below the dot
                                Positioned(
                                  top: minDotY + 6,
                                  left: 0,
                                  right: 0,
                                  height: 14,
                                  child: Center(
                                    child: Text(
                                      settings.tempUnit.format(d.tempMin),
                                      style: const TextStyle(
                                        color: Color(0xFF64B5F6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                // Precip mm label — top of bar zone
                                if (precip > 0)
                                  Positioned(
                                    top: _dateRowH + _iconRowH + _curveH + 4,
                                    left: 0,
                                    right: 0,
                                    height: 14,
                                    child: Center(
                                      child: Text(
                                        precip >= 10
                                            ? '${precip.round()}mm'
                                            : '${precip.toStringAsFixed(1)}mm',
                                        style: const TextStyle(
                                          color: AppColors.accentBlue,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Wind row — below precip
                                Positioned(
                                  top: _dateRowH + _iconRowH + _curveH + 20,
                                  left: 0,
                                  right: 0,
                                  height: 14,
                                  child: Center(
                                    child: Text(
                                      windLabel,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
        Builder(
          builder: (ctx) {
            final unit = ctx.watch<SettingsProvider>().tempUnit.label;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
              child: Row(
                children: [
                  _LegendItem(
                    color: const Color(0xFFFF6B6B),
                    label: 'legendMax'.tr(args: [unit]),
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: const Color(0xFF64B5F6),
                    label: 'legendMin'.tr(args: [unit]),
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: AppColors.accentBlue,
                    label: 'legendRain'.tr(),
                    isBar: true,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _bearingLabel(int deg) {
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return labels[((deg + 22) % 360) ~/ 45];
  }

  String _dateLabel(DateTime date, int index, String todayLabel) {
    if (index == 0) return '$todayLabel\n${DateFormat('M/d').format(date)}';
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
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
    );
    _drawCurve(
      canvas,
      points: List.generate(daily.length, _minOffset),
      color: const Color(0xFF64B5F6),
    );
    _drawPrecipBars(canvas);
  }

  void _drawCurve(Canvas canvas, {required List<Offset> points, required Color color}) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
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

    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = Colors.white.withAlpha(200)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawPrecipBars(Canvas canvas) {
    // bars sit in the bottom part of barZone, below wind row (20px) and mm label (14px)
    const windRowH = 18.0;
    const mmLabelH = 14.0;
    final barMaxH = barZoneH - windRowH - mmLabelH - 6;

    final barPaint = Paint()
      ..color = AppColors.accentBlue.withAlpha(160)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < daily.length; i++) {
      final precip = daily[i].precipitationSum;
      if (precip <= 0) continue;

      final barH = (precip / maxPrecip * barMaxH).clamp(4.0, barMaxH);
      final x = colWidth * i + colWidth * 0.3;
      final barW = colWidth * 0.4;
      // bottom of barZone is y = curveH + barZoneH; bar sits just above bottom
      final top = curveH + barZoneH - barH;

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
      old.daily != daily || old.minTemp != minTemp || old.tempRange != tempRange;
}
