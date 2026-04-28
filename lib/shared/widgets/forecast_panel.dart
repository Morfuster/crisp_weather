import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Overcast-style solid dark panel — no blur, clean rounded rectangle.
class ForecastPanel extends StatelessWidget {
  const ForecastPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.panelBorder, width: 0.5),
      ),
      padding: padding,
      child: child,
    );
  }
}
