import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/hourly_forecast.dart';
import '../../../core/settings/settings_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/forecast_panel.dart';
import '../../../shared/widgets/weather_icon.dart';

class HourlyChart extends StatefulWidget {
  const HourlyChart({super.key, required this.hourly});

  final List<HourlyForecast> hourly;

  @override
  State<HourlyChart> createState() => _HourlyChartState();
}

class _HourlyChartState extends State<HourlyChart> {
  static const _columnWidth = 56.0;
  static const _chartHeight = 80.0;
  static const _precipBarMaxHeight = 36.0;
  static const _topRowHeight = 56.0;
  static const _bottomRowHeight = 40.0;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!_scroll.hasClients) return;
    final now = DateTime.now();
    // Find the index of the first hourly entry at or after now
    int idx = 0;
    for (int i = 0; i < widget.hourly.length; i++) {
      if (!widget.hourly[i].time.isBefore(now)) {
        idx = i;
        break;
      }
    }
    // Scroll so the current hour is the second column (one column of context before it)
    final offset = ((idx - 1) * _columnWidth).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hourly.isEmpty) return const SizedBox.shrink();

    final settings = context.watch<SettingsProvider>();
    final temps = widget.hourly.map((h) => h.temperature).toList();
    final minTemp = temps.reduce(math.min);
    final maxTemp = temps.reduce(math.max);
    final tempRange = (maxTemp - minTemp).clamp(2.0, double.infinity);

    final maxPrecip = widget.hourly
        .map((h) => h.precipitation + h.snowfall)
        .reduce(math.max)
        .clamp(0.1, double.infinity);

    final totalWidth = _columnWidth * widget.hourly.length;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ForecastPanel(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: _topRowHeight + _chartHeight + _bottomRowHeight,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: _topRowHeight,
                      bottom: _bottomRowHeight,
                      child: CustomPaint(
                        painter: _HourlyChartPainter(
                          hourly: widget.hourly,
                          minTemp: minTemp,
                          tempRange: tempRange,
                          maxPrecip: maxPrecip,
                          columnWidth: _columnWidth,
                          chartHeight: _chartHeight,
                          precipBarMaxHeight: _precipBarMaxHeight,
                          now: now,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(widget.hourly.length, (i) {
                        final h = widget.hourly[i];
                        final total = h.precipitation + h.snowfall;
                        final isSnow = h.snowfall > h.precipitation;
                        final timeLabel = DateFormat('h a').format(h.time).toLowerCase();
                        final isNow = i > 0
                            ? widget.hourly[i - 1].time.isBefore(now) && !h.time.isBefore(now)
                            : !h.time.isBefore(now);

                        final norm = (h.temperature - minTemp) / tempRange;
                        final dotY = _topRowHeight +
                            _chartHeight * (1 - norm) * 0.7 +
                            _chartHeight * 0.15;

                        return SizedBox(
                          width: _columnWidth,
                          height: _topRowHeight + _chartHeight + _bottomRowHeight,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 18,
                                child: Center(
                                  child: Text(
                                    timeLabel,
                                    style: TextStyle(
                                      color: isNow
                                          ? AppColors.accentBlue
                                          : AppColors.textTertiary,
                                      fontSize: 10,
                                      fontWeight: isNow
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 18,
                                left: 0,
                                right: 0,
                                height: 24,
                                child: Center(
                                  child: WeatherIcon(code: h.weatherCode, size: 22),
                                ),
                              ),
                              Positioned(
                                top: dotY - 22,
                                left: 0,
                                right: 0,
                                height: 16,
                                child: Center(
                                  child: Text(
                                    settings.tempUnit.format(h.temperature),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (h.precipitationProbability > 0)
                                Positioned(
                                  bottom: _bottomRowHeight - 14,
                                  left: 0,
                                  right: 0,
                                  height: 12,
                                  child: Center(
                                    child: Text(
                                      '${h.precipitationProbability}%',
                                      style: const TextStyle(
                                        color: AppColors.accentBlue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
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
    required this.now,
  });

  final List<HourlyForecast> hourly;
  final double minTemp;
  final double tempRange;
  final double maxPrecip;
  final double columnWidth;
  final double chartHeight;
  final double precipBarMaxHeight;
  final DateTime now;

  double _normTemp(double temp) =>
      ((temp - minTemp) / tempRange).clamp(0.0, 1.0);

  double _dotY(double temp) =>
      chartHeight * (1 - _normTemp(temp)) * 0.7 + chartHeight * 0.15;

  Offset _dotOffset(int i) => Offset(
        columnWidth * i + columnWidth / 2,
        _dotY(hourly[i].temperature),
      );

  @override
  void paint(Canvas canvas, Size size) {
    _drawPrecipBars(canvas, size);
    _drawNowLine(canvas, size);
    _drawTempCurve(canvas);
    _drawDots(canvas);
  }

  void _drawNowLine(Canvas canvas, Size size) {
    // Find fractional x position of 'now' between two hourly entries
    for (int i = 0; i < hourly.length - 1; i++) {
      if (hourly[i].time.isBefore(now) && !hourly[i + 1].time.isBefore(now)) {
        final span = hourly[i + 1].time.difference(hourly[i].time).inSeconds;
        final elapsed = now.difference(hourly[i].time).inSeconds;
        final frac = elapsed / span;
        final x = columnWidth * i + columnWidth / 2 + columnWidth * frac;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          Paint()
            ..color = AppColors.accentBlue.withAlpha(80)
            ..strokeWidth = 1.0,
        );
        break;
      }
    }
  }

  void _drawPrecipBars(Canvas canvas, Size size) {
    for (var i = 0; i < hourly.length; i++) {
      final h = hourly[i];
      final total = h.precipitation + h.snowfall;
      if (total <= 0) continue;

      final barHeight =
          (total / maxPrecip * precipBarMaxHeight).clamp(2.0, precipBarMaxHeight);
      final isSnow = h.snowfall > h.precipitation;
      final barColor = isSnow
          ? const Color(0xFF90A4B8).withAlpha(160)
          : AppColors.accentBlue.withAlpha(120);
      final x = columnWidth * i + columnWidth * 0.25;
      final barWidth = columnWidth * 0.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
          const Radius.circular(3),
        ),
        Paint()..color = barColor,
      );
    }
  }

  void _drawTempCurve(Canvas canvas) {
    if (hourly.length < 2) return;

    final path = Path();
    final fillPath = Path();
    final points = List.generate(hourly.length, _dotOffset);

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, chartHeight);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }

    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accentBlue.withAlpha(80),
            AppColors.accentBlue.withAlpha(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, columnWidth * hourly.length, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accentBlue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawDots(Canvas canvas) {
    for (var i = 0; i < hourly.length; i++) {
      final offset = _dotOffset(i);
      canvas.drawCircle(offset, 4, Paint()..color = AppColors.accentBlue);
      canvas.drawCircle(
        offset,
        4,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_HourlyChartPainter old) =>
      old.hourly != hourly || old.minTemp != minTemp || old.tempRange != tempRange;
}
