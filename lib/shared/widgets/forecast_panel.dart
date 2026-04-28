import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Overcast-style semi-transparent white panel.
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

  Color get _fill => _pressed
      ? AppColors.panelFill.withAlpha(AppColors.panelFill.a ~/ 1.8)
      : AppColors.panelFill;

  @override
  Widget build(BuildContext context) {
    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      padding: widget.padding,
      child: widget.child,
    );

    if (!widget.pressable) return container;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: container,
    );
  }
}
