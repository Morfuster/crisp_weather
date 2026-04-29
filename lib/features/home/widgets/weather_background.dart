import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/theme/animated_weather_painter.dart';
import '../../../shared/theme/panel_opacity.dart' show PanelTheme, scenePanelStyle;

class WeatherBackground extends StatefulWidget {
  const WeatherBackground({
    super.key,
    required this.wmoCode,
    required this.localTime,
    required this.child,
  });

  final int wmoCode;
  final DateTime localTime;
  final Widget child;

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late WeatherScene _scene;
  late WeatherScene _prevScene;

  // Particle pools — generated once per scene, reused every frame
  final _rng = math.Random(42);
  late List<dynamic> _particles; // typed per scene below

  // Lightning flash state
  double _flashPhase = 0;

  @override
  void initState() {
    super.initState();
    _scene = resolveScene(widget.wmoCode, widget.localTime);
    _prevScene = _scene;
    _particles = _buildParticles(_scene);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();

    _controller.addListener(() {
      if (_scene == WeatherScene.stormy) {
        setState(() => _flashPhase = _controller.value);
      }
    });
  }

  @override
  void didUpdateWidget(WeatherBackground old) {
    super.didUpdateWidget(old);
    final next = resolveScene(widget.wmoCode, widget.localTime);
    if (next != _scene) {
      _prevScene = _scene;
      _scene = next;
      _particles = _buildParticles(_scene);
    }
  }

  List<dynamic> _buildParticles(WeatherScene scene) => switch (scene) {
        WeatherScene.rainy       => RainPainter.generate(120, _rng),
        WeatherScene.stormy      => RainPainter.generate(180, _rng),
        WeatherScene.snowy       => SnowPainter.generate(80, _rng),
        WeatherScene.nightClear  => StarsPainter.generate(90, _rng),
        WeatherScene.nightCloudy => StarsPainter.generate(30, _rng),
        _                        => <dynamic>[],
      };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final gradient = sceneGradient(_scene);
        final prevGradient = sceneGradient(_prevScene);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background — animated crossfade on scene change
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              key: ValueKey('gradient_$_scene'),
              builder: (ctx, t, child) => Container(
                decoration: BoxDecoration(
                  gradient: t >= 1.0
                      ? gradient
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: List.generate(
                            gradient.colors.length,
                            (i) => Color.lerp(
                              prevGradient.colors[
                                  i.clamp(0, prevGradient.colors.length - 1)],
                              gradient.colors[i],
                              t,
                            )!,
                          ),
                        ),
                ),
              ),
            ),

            // Particle / effect layer
            ..._buildEffectLayers(progress),

            // Dark overlay for text readability
            Container(color: Colors.black.withAlpha(70)),

            // Content — wrapped with animated panel style
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              key: ValueKey('panel_$_scene'),
              builder: (ctx, t, ch) => PanelTheme(
                style: scenePanelStyle(_prevScene).lerp(scenePanelStyle(_scene), t),
                child: ch!,
              ),
              child: child,
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  List<Widget> _buildEffectLayers(double progress) => switch (_scene) {
        WeatherScene.sunnyDay => [
            CustomPaint(
              painter: SunRaysPainter(progress: progress),
              size: Size.infinite,
            ),
          ],
        WeatherScene.cloudyDay => [
            CustomPaint(
              painter: CloudPainter(progress: progress, isNight: false),
              size: Size.infinite,
            ),
          ],
        WeatherScene.rainy => [
            CustomPaint(
              painter: CloudPainter(progress: progress, isNight: false),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: RainPainter(
                  progress: progress,
                  drops: _particles.cast()),
              size: Size.infinite,
            ),
          ],
        WeatherScene.stormy => [
            CustomPaint(
              painter: CloudPainter(progress: progress, isNight: false),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: RainPainter(
                  progress: progress,
                  drops: _particles.cast()),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: LightningPainter(
                  progress: progress, flashPhase: _flashPhase),
              size: Size.infinite,
            ),
          ],
        WeatherScene.snowy => [
            CustomPaint(
              painter: CloudPainter(progress: progress, isNight: false),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: SnowPainter(
                  progress: progress,
                  flakes: _particles.cast()),
              size: Size.infinite,
            ),
          ],
        WeatherScene.nightClear => [
            CustomPaint(
              painter: StarsPainter(
                  progress: progress,
                  stars: _particles.cast()),
              size: Size.infinite,
            ),
          ],
        WeatherScene.nightCloudy => [
            CustomPaint(
              painter: StarsPainter(
                  progress: progress,
                  stars: _particles.cast()),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: CloudPainter(progress: progress, isNight: true),
              size: Size.infinite,
            ),
          ],
        WeatherScene.foggy => [
            CustomPaint(
              painter: FogPainter(progress: progress),
              size: Size.infinite,
            ),
          ],
      };
}
