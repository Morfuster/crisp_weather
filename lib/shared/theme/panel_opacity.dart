import 'package:flutter/material.dart';

import 'animated_weather_painter.dart';

class PanelStyle {
  const PanelStyle({
    required this.baseColor,
    required this.fillOpacity,
    required this.borderOpacity,
  });

  final Color baseColor;   // black or white — never grey
  final double fillOpacity;
  final double borderOpacity;

  Color get fill => baseColor.withValues(alpha: fillOpacity);
  Color get border => baseColor.withValues(alpha: borderOpacity);

  PanelStyle lerp(PanelStyle other, double t) => PanelStyle(
        baseColor: Color.lerp(baseColor, other.baseColor, t)!,
        fillOpacity: lerpDouble(fillOpacity, other.fillOpacity, t),
        borderOpacity: lerpDouble(borderOpacity, other.borderOpacity, t),
      );

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

// Light backgrounds (sunny, cloudy, snowy, foggy) → dark card so text pops
// Dark backgrounds (night, rainy, stormy) → light card to stay visible
PanelStyle scenePanelStyle(WeatherScene scene) => switch (scene) {
      WeatherScene.sunnyDay    => const PanelStyle(baseColor: Colors.black, fillOpacity: 0.32, borderOpacity: 0.18),
      WeatherScene.cloudyDay   => const PanelStyle(baseColor: Colors.black, fillOpacity: 0.36, borderOpacity: 0.18),
      WeatherScene.foggy       => const PanelStyle(baseColor: Colors.black, fillOpacity: 0.34, borderOpacity: 0.16),
      WeatherScene.snowy       => const PanelStyle(baseColor: Colors.black, fillOpacity: 0.30, borderOpacity: 0.16),
      WeatherScene.rainy       => const PanelStyle(baseColor: Colors.white, fillOpacity: 0.14, borderOpacity: 0.20),
      WeatherScene.stormy      => const PanelStyle(baseColor: Colors.white, fillOpacity: 0.12, borderOpacity: 0.18),
      WeatherScene.nightClear  => const PanelStyle(baseColor: Colors.white, fillOpacity: 0.13, borderOpacity: 0.22),
      WeatherScene.nightCloudy => const PanelStyle(baseColor: Colors.white, fillOpacity: 0.12, borderOpacity: 0.20),
    };

class PanelTheme extends InheritedWidget {
  const PanelTheme({
    super.key,
    required this.style,
    required super.child,
  });

  final PanelStyle style;

  static PanelStyle of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<PanelTheme>();
    return w?.style ?? const PanelStyle(baseColor: Colors.white, fillOpacity: 0.14, borderOpacity: 0.20);
  }

  @override
  bool updateShouldNotify(PanelTheme old) =>
      old.style.baseColor != style.baseColor ||
      old.style.fillOpacity != style.fillOpacity;
}
