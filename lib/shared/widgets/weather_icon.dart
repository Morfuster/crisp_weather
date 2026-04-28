import 'dart:math' as math;

import 'package:flutter/material.dart';

// WMO code → set of layers to draw
enum _Layer { sun, cloud, rain, snow, lightning, fog }

const Map<int, List<_Layer>> _wmoLayers = {
  0:  [_Layer.sun],
  1:  [_Layer.sun],
  2:  [_Layer.sun, _Layer.cloud],
  3:  [_Layer.cloud],
  45: [_Layer.cloud, _Layer.fog],
  48: [_Layer.cloud, _Layer.fog],
  51: [_Layer.cloud, _Layer.rain],
  53: [_Layer.cloud, _Layer.rain],
  55: [_Layer.cloud, _Layer.rain],
  56: [_Layer.cloud, _Layer.rain],
  57: [_Layer.cloud, _Layer.rain],
  61: [_Layer.cloud, _Layer.rain],
  63: [_Layer.cloud, _Layer.rain],
  65: [_Layer.cloud, _Layer.rain],
  66: [_Layer.cloud, _Layer.rain],
  67: [_Layer.cloud, _Layer.rain],
  71: [_Layer.cloud, _Layer.snow],
  73: [_Layer.cloud, _Layer.snow],
  75: [_Layer.cloud, _Layer.snow],
  77: [_Layer.cloud, _Layer.snow],
  80: [_Layer.sun, _Layer.cloud, _Layer.rain],
  81: [_Layer.sun, _Layer.cloud, _Layer.rain],
  82: [_Layer.sun, _Layer.cloud, _Layer.rain],
  85: [_Layer.sun, _Layer.cloud, _Layer.snow],
  86: [_Layer.sun, _Layer.cloud, _Layer.snow],
  95: [_Layer.cloud, _Layer.lightning],
  96: [_Layer.cloud, _Layer.lightning, _Layer.rain],
  99: [_Layer.cloud, _Layer.lightning, _Layer.rain],
};

List<_Layer> _layersFor(int code) =>
    _wmoLayers[code] ?? [_Layer.cloud];

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key, required this.code, required this.size});

  final int code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WeatherIconPainter(layers: _layersFor(code)),
      ),
    );
  }
}

class _WeatherIconPainter extends CustomPainter {
  const _WeatherIconPainter({required this.layers});

  final List<_Layer> layers;

  @override
  void paint(Canvas canvas, Size size) {
    final hasSun = layers.contains(_Layer.sun);
    final hasCloud = layers.contains(_Layer.cloud);
    final hasRain = layers.contains(_Layer.rain);
    final hasSnow = layers.contains(_Layer.snow);
    final hasLightning = layers.contains(_Layer.lightning);
    final hasFog = layers.contains(_Layer.fog);

    // Determine layout offsets based on combination
    final sunOnly = hasSun && !hasCloud;
    final cloudOnly = hasCloud && !hasSun;

    // Sun center: upper-left when cloud present, true center when alone
    final sunCx = sunOnly ? size.width * 0.5 : size.width * 0.38;
    final sunCy = sunOnly ? size.height * 0.5 : size.height * 0.35;
    final sunR = sunOnly ? size.width * 0.28 : size.width * 0.22;

    // Cloud center: lower-right when sun present
    final cloudCx = cloudOnly ? size.width * 0.5 : size.width * 0.58;
    final cloudCy = cloudOnly ? size.height * 0.52 : size.height * 0.58;
    final cloudW = cloudOnly ? size.width * 0.72 : size.width * 0.58;
    final cloudH = cloudOnly ? size.height * 0.36 : size.height * 0.30;

    // Precipitation zone: below the cloud
    final precipTop = hasCloud
        ? cloudCy + cloudH * 0.5
        : size.height * 0.62;

    if (hasSun) _drawSun(canvas, size, sunCx, sunCy, sunR);
    if (hasCloud) _drawCloud(canvas, cloudCx, cloudCy, cloudW, cloudH);
    if (hasFog) _drawFog(canvas, size, cloudCx, cloudCy + cloudH * 0.6);
    if (hasRain) _drawRain(canvas, size, cloudCx, precipTop, cloudW);
    if (hasSnow) _drawSnow(canvas, size, cloudCx, precipTop, cloudW);
    if (hasLightning) _drawLightning(canvas, size, cloudCx, precipTop);
  }

  // ── Sun ──────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, Size size, double cx, double cy, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFD60A)
      ..style = PaintingStyle.fill;

    // Core disc
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD60A)
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round;

    final rayCount = 8;
    final inner = r * 1.3;
    final outer = r * 1.85;
    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * inner, cy + math.sin(angle) * inner),
        Offset(cx + math.cos(angle) * outer, cy + math.sin(angle) * outer),
        rayPaint,
      );
    }
  }

  // ── Cloud ─────────────────────────────────────────────────────────────────

  void _drawCloud(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(230)
      ..style = PaintingStyle.fill;
    final shadow = Paint()
      ..color = Colors.black.withAlpha(30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = _cloudPath(cx, cy, w, h);
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }

  Path _cloudPath(double cx, double cy, double w, double h) {
    // Three overlapping circles forming a cloud silhouette
    final r = h * 0.5;
    final leftX = cx - w * 0.28;
    final rightX = cx + w * 0.24;
    final midY = cy;

    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(leftX, midY), radius: r * 0.78))
      ..addOval(Rect.fromCircle(center: Offset(cx, midY - h * 0.18), radius: r))
      ..addOval(Rect.fromCircle(center: Offset(rightX, midY + h * 0.04), radius: r * 0.72));

    // Fill the bottom rectangle to merge the circles into a solid base
    path.addRect(Rect.fromLTRB(
      leftX - r * 0.78,
      midY,
      rightX + r * 0.72,
      midY + r * 0.72,
    ));
    return path;
  }

  // ── Rain ─────────────────────────────────────────────────────────────────

  void _drawRain(Canvas canvas, Size size, double cx, double top, double cloudW) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;

    final spacing = cloudW * 0.28;
    final startX = cx - spacing;
    const dropLen = 0.14; // fraction of size.height

    for (var i = 0; i < 3; i++) {
      final x = startX + i * spacing;
      final yOff = (i % 2 == 0 ? 0.0 : size.height * 0.05);
      canvas.drawLine(
        Offset(x, top + yOff),
        Offset(x - size.width * 0.04, top + yOff + size.height * dropLen),
        paint,
      );
    }
  }

  // ── Snow ──────────────────────────────────────────────────────────────────

  void _drawSnow(Canvas canvas, Size size, double cx, double top, double cloudW) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final spacing = cloudW * 0.28;
    final startX = cx - spacing;
    final r = size.width * 0.07;

    for (var i = 0; i < 3; i++) {
      final x = startX + i * spacing;
      final y = top + size.height * 0.1 + (i % 2 == 0 ? 0 : size.height * 0.06);

      // Snowflake: 3 crossed lines
      for (var a = 0; a < 3; a++) {
        final angle = a * math.pi / 3;
        canvas.drawLine(
          Offset(x + math.cos(angle) * r, y + math.sin(angle) * r),
          Offset(x - math.cos(angle) * r, y - math.sin(angle) * r),
          paint,
        );
      }
    }
  }

  // ── Lightning ─────────────────────────────────────────────────────────────

  void _drawLightning(Canvas canvas, Size size, double cx, double top) {
    final paint = Paint()
      ..color = const Color(0xFFFFD60A)
      ..style = PaintingStyle.fill;

    final bx = cx;
    final by = top;
    final s = size.width * 0.18;

    // Simple bolt: two triangles
    final path = Path()
      ..moveTo(bx, by)
      ..lineTo(bx - s * 0.6, by + s * 1.1)
      ..lineTo(bx + s * 0.1, by + s * 1.1)
      ..lineTo(bx - s * 0.2, by + s * 2.0)
      ..lineTo(bx + s * 0.7, by + s * 0.85)
      ..lineTo(bx + s * 0.05, by + s * 0.85)
      ..close();

    canvas.drawPath(path, paint);
  }

  // ── Fog ───────────────────────────────────────────────────────────────────

  void _drawFog(Canvas canvas, Size size, double cx, double top) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(140)
      ..strokeWidth = size.height * 0.07
      ..strokeCap = StrokeCap.round;

    final w = size.width * 0.6;
    for (var i = 0; i < 3; i++) {
      final y = top + i * size.height * 0.1;
      canvas.drawLine(
        Offset(cx - w / 2, y),
        Offset(cx + w / 2, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WeatherIconPainter old) => old.layers != layers;
}
