import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/daily_forecast.dart';
import '../../../core/models/hourly_forecast.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';
import 'daily_detail_sheet.dart';

class DailyChart extends StatelessWidget {
  const DailyChart({super.key, required this.daily, required this.allHourly});

  final List<DailyForecast> daily;
  final List<HourlyForecast> allHourly;

  static const _colWidth = 72.0;
  static const _dateRowH = 36.0;
  static const _iconRowH = 38.0;
  static const _curveH = 120.0;
  static const _barZoneH = 72.0;

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
                      // Curves + bars + temp labels all in painter (exact coords)
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
                            tempUnit: settings.tempUnit,
                            windUnit: settings.windUnit,
                          ),
                        ),
                      ),
                      // Per-column overlay: date, icon, precip mm, wind
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(daily.length, (i) {
                          final d = daily[i];
                          final todayLabel = 'today'.tr();
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
                              ],
                            ),
                          );
                        }),
                      ),
                      // Tap overlay — one transparent tile per column
                      Row(
                        children: List.generate(daily.length, (i) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => showDailyDetail(
                              context,
                              day: daily[i],
                              allHourly: allHourly,
                            ),
                            child: SizedBox(
                              width: _colWidth,
                              height: totalH,
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
    required this.tempUnit,
    required this.windUnit,
  });

  final List<DailyForecast> daily;
  final double minTemp;
  final double tempRange;
  final double maxPrecip;
  final double colWidth;
  final double curveH;
  final double barZoneH;
  final TempUnit tempUnit;
  final WindUnit windUnit;

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
    _drawTempLabels(canvas);
    _drawPrecipBars(canvas);
    _drawPrecipLabels(canvas);
    _drawWindLabels(canvas);
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

  void _drawTempLabels(Canvas canvas) {
    for (var i = 0; i < daily.length; i++) {
      final d = daily[i];
      final cx = colWidth * i + colWidth / 2;

      // Max label — below max dot
      _drawLabel(
        canvas,
        text: tempUnit.format(d.tempMax),
        center: Offset(cx, _dotY(d.tempMax) + 14),
        color: const Color(0xFFFF6B6B),
      );

      // Min label — below min dot
      _drawLabel(
        canvas,
        text: tempUnit.format(d.tempMin),
        center: Offset(cx, _dotY(d.tempMin) + 14),
        color: const Color(0xFF64B5F6),
      );
    }
  }

  void _drawLabel(Canvas canvas, {required String text, required Offset center, required Color color}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ))
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);

    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: colWidth));

    canvas.drawParagraph(
      paragraph,
      Offset(center.dx - colWidth / 2, center.dy - paragraph.height / 2),
    );
  }

  // Layout within barZone (y=curveH is top of barZone):
  //   curveH + 0           → bar top area (barMaxH tall)
  //   curveH + barMaxH + 2 → mm label (12px)
  //   curveH + barMaxH + 16→ wind label (12px)
  static const _barMaxH = 38.0;
  static const _mmLabelY = _barMaxH + 4.0;   // below bar
  static const _windLabelY = _barMaxH + 18.0; // below mm

  void _drawPrecipBars(Canvas canvas) {
    final barPaint = Paint()
      ..color = AppColors.accentBlue.withAlpha(160)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < daily.length; i++) {
      final precip = daily[i].precipitationSum;
      if (precip <= 0) continue;

      final barH = (precip / maxPrecip * _barMaxH).clamp(4.0, _barMaxH);
      final x = colWidth * i + colWidth * 0.3;
      final barW = colWidth * 0.4;
      // bar bottom is at curveH + barMaxH, grows upward
      final top = curveH + _barMaxH - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barW, barH),
          const Radius.circular(3),
        ),
        barPaint,
      );
    }
  }

  void _drawPrecipLabels(Canvas canvas) {
    for (var i = 0; i < daily.length; i++) {
      final precip = daily[i].precipitationSum;
      if (precip <= 0) continue;
      final text = precip >= 10 ? '${precip.round()}mm' : '${precip.toStringAsFixed(1)}mm';
      _drawLabel(
        canvas,
        text: text,
        center: Offset(colWidth * i + colWidth / 2, curveH + _mmLabelY + 6),
        color: AppColors.accentBlue,
      );
    }
  }

  void _drawWindLabels(Canvas canvas) {
    const bearings = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    for (var i = 0; i < daily.length; i++) {
      final d = daily[i];
      final bearing = bearings[((d.windDirectionDominant + 22) % 360) ~/ 45];
      final text = '${windUnit.format(d.windSpeedMax)} $bearing';
      _drawLabel(
        canvas,
        text: text,
        center: Offset(colWidth * i + colWidth / 2, curveH + _windLabelY + 6),
        color: Colors.white54,
      );
    }
  }

  @override
  bool shouldRepaint(_DailyChartPainter old) =>
      old.daily != daily ||
      old.minTemp != minTemp ||
      old.tempRange != tempRange ||
      old.tempUnit != tempUnit ||
      old.windUnit != windUnit;
}
