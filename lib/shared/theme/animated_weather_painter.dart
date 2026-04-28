import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

enum WeatherScene { sunnyDay, cloudyDay, rainy, snowy, stormy, nightClear, nightCloudy, foggy }

WeatherScene resolveScene(int wmoCode, DateTime localTime) {
  final isNight = localTime.hour < 6 || localTime.hour >= 20;

  if (wmoCode == 95 || wmoCode == 96 || wmoCode == 99) return WeatherScene.stormy;
  if (wmoCode >= 71 && wmoCode <= 77 || wmoCode == 85 || wmoCode == 86) return WeatherScene.snowy;
  if (wmoCode >= 51 && wmoCode <= 67 || wmoCode >= 80 && wmoCode <= 82) return WeatherScene.rainy;
  if (wmoCode == 45 || wmoCode == 48) return WeatherScene.foggy;

  if (isNight) {
    if (wmoCode == 2 || wmoCode == 3) return WeatherScene.nightCloudy;
    return WeatherScene.nightClear;
  }
  if (wmoCode == 2 || wmoCode == 3) return WeatherScene.cloudyDay;
  return WeatherScene.sunnyDay;
}

LinearGradient sceneGradient(WeatherScene scene) => switch (scene) {
      WeatherScene.sunnyDay    => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.sunnyTop, AppColors.sunnyBottom]),
      WeatherScene.cloudyDay   => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.cloudyTop, AppColors.cloudyBottom]),
      WeatherScene.rainy       => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.rainyTop, AppColors.rainyBottom]),
      WeatherScene.snowy       => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.snowyTop, AppColors.snowyBottom]),
      WeatherScene.stormy      => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.stormTop, AppColors.stormBottom]),
      WeatherScene.nightClear  => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.nightTop, AppColors.nightBottom]),
      WeatherScene.nightCloudy => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.nightCloudyTop, AppColors.nightCloudyBottom]),
      WeatherScene.foggy       => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6B7F95), Color(0xFF3A4A5C)]),
    };

// ---------------------------------------------------------------------------
// Sun rays painter (sunny day)
// ---------------------------------------------------------------------------

class SunRaysPainter extends CustomPainter {
  const SunRaysPainter({required this.progress});

  final double progress; // 0..1 looping

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.72;
    final cy = size.height * 0.18;
    const rayCount = 12;
    final angle = progress * 2 * math.pi;

    for (var i = 0; i < rayCount; i++) {
      final a = angle + (i / rayCount) * 2 * math.pi;
      final inner = size.width * 0.09;
      final outer = size.width * (0.18 + 0.06 * math.sin(progress * 2 * math.pi + i));
      final opacity = 0.06 + 0.04 * math.sin(progress * 2 * math.pi + i * 0.7);
      final paint = Paint()
        ..color = Colors.yellow.withAlpha((opacity * 255).round())
        ..strokeWidth = size.width * 0.018
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + math.cos(a) * inner, cy + math.sin(a) * inner),
        Offset(cx + math.cos(a) * outer, cy + math.sin(a) * outer),
        paint,
      );
    }

    // Glow disc
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withAlpha(40),
          Colors.yellow.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size.width * 0.28));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.28, glowPaint);
  }

  @override
  bool shouldRepaint(SunRaysPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Cloud layer (cloudy / night-cloudy)
// ---------------------------------------------------------------------------

class CloudSpec {
  const CloudSpec(this.yFrac, this.xFrac, this.scale, this.speed, this.alpha);
  final double yFrac, xFrac, scale, speed, alpha;
}

const _dayClouds = [
  CloudSpec(0.08, 0.0,  1.1, 0.012, 0.55),
  CloudSpec(0.22, 0.3,  0.8, 0.018, 0.40),
  CloudSpec(0.35, 0.6,  1.3, 0.008, 0.35),
  CloudSpec(0.50, 0.1,  0.7, 0.022, 0.30),
];

const _nightClouds = [
  CloudSpec(0.10, 0.0,  1.2, 0.010, 0.28),
  CloudSpec(0.30, 0.5,  0.9, 0.015, 0.20),
];

class CloudPainter extends CustomPainter {
  const CloudPainter({required this.progress, required this.isNight});

  final double progress;
  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    final specs = isNight ? _nightClouds : _dayClouds;
    for (final spec in specs) {
      final xOffset = ((spec.xFrac + spec.speed * progress) % 1.2) - 0.1;
      _drawCloud(
        canvas,
        Offset(xOffset * size.width, spec.yFrac * size.height),
        spec.scale * size.width * 0.38,
        spec.alpha,
        isNight,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double r, double alpha, bool night) {
    final color = night
        ? Colors.blueGrey.withAlpha((alpha * 255).round())
        : Colors.white.withAlpha((alpha * 255).round());
    final paint = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 2.2, height: r * 0.9), paint);
    canvas.drawCircle(center.translate(-r * 0.45, -r * 0.22), r * 0.52, paint);
    canvas.drawCircle(center.translate(r * 0.20, -r * 0.35), r * 0.62, paint);
    canvas.drawCircle(center.translate(r * 0.60, -r * 0.18), r * 0.44, paint);
  }

  @override
  bool shouldRepaint(CloudPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Rain painter
// ---------------------------------------------------------------------------

class RainDrop {
  RainDrop(this.x, this.y, this.speed, this.length, this.alpha);
  double x, y;
  final double speed, length, alpha;
}

class RainPainter extends CustomPainter {
  RainPainter({required this.progress, required this.drops});

  final double progress;
  final List<RainDrop> drops;

  static List<RainDrop> generate(int count, math.Random rng) => List.generate(
        count,
        (_) => RainDrop(
          rng.nextDouble(),
          rng.nextDouble(),
          0.004 + rng.nextDouble() * 0.006,
          0.04 + rng.nextDouble() * 0.06,
          0.3 + rng.nextDouble() * 0.5,
        ),
      );

  @override
  void paint(Canvas canvas, Size size) {
    const angle = 0.25; // radians tilt
    for (final d in drops) {
      final y = (d.y + d.speed * progress * 60) % 1.1;
      final x = d.x + math.sin(angle) * y * 0.3;
      final paint = Paint()
        ..color = const Color(0xFF9EC8E8).withAlpha((d.alpha * 255).round())
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      final top = Offset(x * size.width, y * size.height);
      final bot = Offset(
        top.dx + math.sin(angle) * d.length * size.height,
        top.dy + math.cos(angle) * d.length * size.height,
      );
      canvas.drawLine(top, bot, paint);
    }
  }

  @override
  bool shouldRepaint(RainPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Snow painter
// ---------------------------------------------------------------------------

class SnowFlake {
  SnowFlake(this.x, this.y, this.radius, this.speed, this.drift, this.phase);
  double x, y;
  final double radius, speed, drift, phase;
}

class SnowPainter extends CustomPainter {
  SnowPainter({required this.progress, required this.flakes});

  final double progress;
  final List<SnowFlake> flakes;

  static List<SnowFlake> generate(int count, math.Random rng) => List.generate(
        count,
        (_) => SnowFlake(
          rng.nextDouble(),
          rng.nextDouble(),
          1.5 + rng.nextDouble() * 3.5,
          0.001 + rng.nextDouble() * 0.003,
          0.0015 + rng.nextDouble() * 0.002,
          rng.nextDouble() * 2 * math.pi,
        ),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(200);
    for (final f in flakes) {
      final y = (f.y + f.speed * progress * 60) % 1.05;
      final x = f.x + f.drift * math.sin(progress * 60 * f.speed * 3 + f.phase);
      canvas.drawCircle(
        Offset((x % 1.0) * size.width, y * size.height),
        f.radius,
        paint..color = Colors.white.withAlpha(180),
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Lightning flash (storm)
// ---------------------------------------------------------------------------

class LightningPainter extends CustomPainter {
  const LightningPainter({required this.progress, required this.flashPhase});

  final double progress;
  final double flashPhase; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    // Flash pulse — brief white overlay
    final flashProgress = (flashPhase * 8) % 1.0;
    if (flashProgress < 0.08) {
      final opacity = (1.0 - flashProgress / 0.08) * 0.18;
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withAlpha((opacity * 255).round()),
      );
    }

    // Bolt — only visible for a short window
    if (flashProgress < 0.12) {
      _drawBolt(canvas, size, flashProgress);
    }
  }

  void _drawBolt(Canvas canvas, Size size, double t) {
    final opacity = (1.0 - t / 0.12).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.yellowAccent.withAlpha((opacity * 220).round())
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width * 0.55;
    final points = [
      Offset(cx, size.height * 0.05),
      Offset(cx - size.width * 0.05, size.height * 0.22),
      Offset(cx + size.width * 0.03, size.height * 0.22),
      Offset(cx - size.width * 0.07, size.height * 0.45),
    ];
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LightningPainter old) =>
      old.progress != progress || old.flashPhase != flashPhase;
}

// ---------------------------------------------------------------------------
// Stars (night clear)
// ---------------------------------------------------------------------------

class StarPoint {
  const StarPoint(this.x, this.y, this.radius, this.phase);
  final double x, y, radius, phase;
}

class StarsPainter extends CustomPainter {
  StarsPainter({required this.progress, required this.stars});

  final double progress;
  final List<StarPoint> stars;

  static List<StarPoint> generate(int count, math.Random rng) => List.generate(
        count,
        (_) => StarPoint(
          rng.nextDouble(),
          rng.nextDouble() * 0.65,
          0.8 + rng.nextDouble() * 1.8,
          rng.nextDouble() * 2 * math.pi,
        ),
      );

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = 0.5 + 0.5 * math.sin(progress * 6 + s.phase);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.radius,
        Paint()..color = Colors.white.withAlpha((twinkle * 200).round()),
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Fog painter
// ---------------------------------------------------------------------------

class FogPainter extends CustomPainter {
  const FogPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const bandCount = 6;
    for (var i = 0; i < bandCount; i++) {
      final yBase = (i / bandCount + progress * 0.04 * (i.isEven ? 1 : -1)) % 1.0;
      final yCenter = yBase * size.height;
      final opacity = 0.12 + 0.08 * math.sin(progress * 2 * math.pi + i);
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha((opacity * 255).round()),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, yCenter - 40, size.width, 80));
      canvas.drawRect(
        Rect.fromLTWH(0, yCenter - 40, size.width, 80),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FogPainter old) => old.progress != progress;
}
