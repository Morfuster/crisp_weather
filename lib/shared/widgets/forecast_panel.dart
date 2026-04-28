import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Overcast-style solid light-grey panel with dark text.
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
      ),
      padding: padding,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.panelText),
        child: IconTheme.merge(
          data: const IconThemeData(color: AppColors.panelText),
          child: child,
        ),
      ),
    );
  }
}
