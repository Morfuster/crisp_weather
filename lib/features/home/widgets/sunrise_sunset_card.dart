import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/forecast_panel.dart';

class SunriseSunsetCard extends StatelessWidget {
  const SunriseSunsetCard({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.now,
  });

  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sunriseLabel = DateFormat('h:mm a').format(sunrise).toLowerCase();
    final sunsetLabel = DateFormat('h:mm a').format(sunset).toLowerCase();

    final totalDaySeconds = sunset.difference(sunrise).inSeconds.toDouble();
    final elapsedSeconds = now.difference(sunrise).inSeconds.toDouble();
    final progress = (elapsedSeconds / totalDaySeconds).clamp(0.0, 1.0);

    return ForecastPanel(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'sunriseSunset'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: CustomPaint(
              size: Size.infinite,
              painter: _SunArcPainter(progress: progress),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(
                icon: Icons.wb_sunny_rounded,
                label: sunriseLabel,
                color: const Color(0xFFFFB74D),
              ),
              _TimeLabel(
                icon: Icons.nights_stay_rounded,
                label: sunsetLabel,
                color: const Color(0xFF9575CD),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
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
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  const _SunArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const dotR = 6.0;
    const strokeW = 2.5;
    const radius = 56.0;

    final cx = size.width / 2;
    final cy = size.height - dotR;

    final center = Offset(cx, cy);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Background track arc (left → top → right)
    canvas.drawArc(
      arcRect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white12
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        arcRect,
        math.pi,
        math.pi * progress,
        false,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFB74D), Color(0xFFFF7043)],
          ).createShader(arcRect)
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Sun dot position along the arc
    final angle = math.pi + math.pi * progress;
    final sunPos = Offset(
      cx + radius * math.cos(angle),
      cy + radius * math.sin(angle),
    );

    canvas.drawCircle(sunPos, dotR, Paint()..color = const Color(0xFFFFB74D));
    canvas.drawCircle(
      sunPos,
      dotR,
      Paint()
        ..color = const Color(0xFFFFE082).withAlpha(180)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}
