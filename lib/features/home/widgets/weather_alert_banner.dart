import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WeatherAlertBanner extends StatefulWidget {
  const WeatherAlertBanner({super.key, required this.wmoCode});

  final int wmoCode;

  @override
  State<WeatherAlertBanner> createState() => _WeatherAlertBannerState();
}

class _WeatherAlertBannerState extends State<WeatherAlertBanner> {
  bool _dismissed = false;
  int? _lastCode;

  @override
  void didUpdateWidget(WeatherAlertBanner old) {
    super.didUpdateWidget(old);
    if (widget.wmoCode != _lastCode) {
      _dismissed = false;
      _lastCode = widget.wmoCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || !_isAlertCode(widget.wmoCode)) return const SizedBox.shrink();

    final (icon, color, message) = _alertInfo(widget.wmoCode);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlpha(120), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'weatherAlert'.tr(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _dismissed = true),
                  child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isAlertCode(int code) => _alertInfo(code).$3.isNotEmpty;

  (IconData, Color, String) _alertInfo(int code) {
    if (code == 95 || code == 96 || code == 99) {
      return (
        Icons.bolt_rounded,
        const Color(0xFFFFB300),
        'wmo$code'.tr(),
      );
    }
    if (code == 82) {
      return (
        Icons.water_rounded,
        const Color(0xFF42A5F5),
        'wmo$code'.tr(),
      );
    }
    if (code == 75 || code == 86) {
      return (
        Icons.ac_unit_rounded,
        const Color(0xFF90CAF9),
        'wmo$code'.tr(),
      );
    }
    if (code == 65 || code == 67) {
      return (
        Icons.water_drop_rounded,
        const Color(0xFF64B5F6),
        'wmo$code'.tr(),
      );
    }
    return (Icons.info_outline_rounded, Colors.white54, '');
  }
}
