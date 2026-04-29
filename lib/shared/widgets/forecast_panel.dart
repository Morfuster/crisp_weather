import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/panel_opacity.dart';

/// Adaptive glass panel — dark-tinted on light backgrounds, light-tinted on dark.
/// Style is provided by [PanelTheme] from the weather background layer.
/// Dims slightly on press when [pressable] is true.
class ForecastPanel extends StatefulWidget {
  const ForecastPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.pressable = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool pressable;

  @override
  State<ForecastPanel> createState() => _ForecastPanelState();
}

class _ForecastPanelState extends State<ForecastPanel> {
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final style = PanelTheme.of(context);
    final pressMultiplier = _pressed ? 1.6 : 1.0;
    final fillColor = style.baseColor.withValues(
      alpha: (style.fillOpacity * pressMultiplier).clamp(0.0, 1.0),
    );
    final borderColor = style.border;
    final radius = BorderRadius.circular(widget.borderRadius);

    Widget panel = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (!widget.pressable) return panel;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: panel,
    );
  }
}
