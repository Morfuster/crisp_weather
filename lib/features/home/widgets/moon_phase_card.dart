import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/forecast_panel.dart';

// Known new moon: 2000-01-06 18:14 UTC
const _newMoonEpoch = 2451550.1;
const _synodicMonth = 29.530588853; // days

double _moonAge(DateTime date) {
  // Julian Day Number
  final jd = 367 * date.year -
      (7 * (date.year + ((date.month + 9) ~/ 12)) ~/ 4) +
      (275 * date.month ~/ 9) +
      date.day +
      1721013.5 +
      (date.hour + date.minute / 60) / 24.0;
  final age = (jd - _newMoonEpoch) % _synodicMonth;
  return age < 0 ? age + _synodicMonth : age;
}

class MoonPhaseCard extends StatelessWidget {
  const MoonPhaseCard({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _moonAge(date);
    final fraction = age / _synodicMonth; // 0=new, 0.5=full, 1=new again
    final phaseName = _phaseName(fraction);
    final illumination = _illumination(fraction);

    return ForecastPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nightlight_round, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'moonPhase'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _MoonPainter(fraction: fraction),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phaseName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${illumination.round()}% ${'illuminated'.tr()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _phaseName(double fraction) {
    if (fraction < 0.03 || fraction > 0.97) return 'moonNew'.tr();
    if (fraction < 0.22) return 'moonWaxingCrescent'.tr();
    if (fraction < 0.28) return 'moonFirstQuarter'.tr();
    if (fraction < 0.47) return 'moonWaxingGibbous'.tr();
    if (fraction < 0.53) return 'moonFull'.tr();
    if (fraction < 0.72) return 'moonWaningGibbous'.tr();
    if (fraction < 0.78) return 'moonLastQuarter'.tr();
    return 'moonWaningCrescent'.tr();
  }

  double _illumination(double fraction) {
    // fraction 0=new(0%), 0.5=full(100%), 1=new(0%)
    return (1 - math.cos(2 * math.pi * fraction)) / 2 * 100;
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter({required this.fraction});

  final double fraction; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 1;

    // Dark moon background
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFF1A1A2E),
    );

    // Illuminated portion — use clip + fill technique
    final isWaxing = fraction <= 0.5;
    final phase = isWaxing ? fraction * 2 : (fraction - 0.5) * 2; // 0..1

    final clipPath = Path();
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    if (fraction < 0.03 || fraction > 0.97) {
      // New moon — no lit area
    } else if (fraction > 0.47 && fraction < 0.53) {
      // Full moon
      clipPath.addOval(rect);
      canvas.drawPath(clipPath, Paint()..color = const Color(0xFFE8E8C8));
    } else {
      // Draw lit half: always right half for waxing, left for waning
      // then overlay an ellipse to create crescent/gibbous shape
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(
        isWaxing ? cx : 0,
        0,
        isWaxing ? cx : cx,
        size.height,
      ));
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFE8E8C8));
      canvas.restore();

      // Overlay dark ellipse to carve crescent or gibbous
      final ellipseXRadius = r * (1 - phase * 2).abs();
      final ellipseColor = phase < 0.5
          ? (isWaxing ? const Color(0xFF1A1A2E) : const Color(0xFFE8E8C8))
          : (isWaxing ? const Color(0xFFE8E8C8) : const Color(0xFF1A1A2E));

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: ellipseXRadius * 2,
          height: r * 2,
        ),
        Paint()..color = ellipseColor,
      );
    }

    // Outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_MoonPainter old) => old.fraction != fraction;
}
