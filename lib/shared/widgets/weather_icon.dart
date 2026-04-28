import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key, required this.code, required this.size});

  final int code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(_iconFor(code), size: size, color: _colorFor(code));
  }

  static IconData _iconFor(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1) return Icons.wb_sunny_outlined;
    if (code == 2) return Icons.cloud_queue_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if (code >= 61 && code <= 67) return Icons.umbrella_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.water_drop_rounded;
    if (code == 85 || code == 86) return Icons.cloudy_snowing;
    if (code == 95 || code == 96 || code == 99) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  static Color _colorFor(int code) {
    if (code == 0 || code == 1) return AppColors.accentYellow;
    if (code == 2 || code == 3) return AppColors.textSecondary;
    if (code == 45 || code == 48) return AppColors.textTertiary;
    if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
      return AppColors.accentBlue;
    }
    if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      return Colors.white;
    }
    if (code == 95 || code == 96 || code == 99) return AppColors.accentOrange;
    return AppColors.textSecondary;
  }
}
