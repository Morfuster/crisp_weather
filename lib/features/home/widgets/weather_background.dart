import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/theme/weather_background_image.dart';
import '../../../shared/theme/weather_gradients.dart';

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

class _WeatherBackgroundState extends State<WeatherBackground> {
  static final Map<String, bool> _assetExistsCache = {};

  String? _confirmedAsset;
  String? _lastCandidate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAsset();
  }

  @override
  void didUpdateWidget(WeatherBackground old) {
    super.didUpdateWidget(old);
    if (old.wmoCode != widget.wmoCode) {
      _checkAsset();
    }
  }

  void _checkAsset() {
    final candidate = resolveBackgroundAsset(widget.wmoCode, widget.localTime);
    if (candidate == _lastCandidate) return;
    _lastCandidate = candidate;

    if (candidate == null) {
      setState(() => _confirmedAsset = null);
      return;
    }

    if (_assetExistsCache.containsKey(candidate)) {
      setState(() =>
          _confirmedAsset = _assetExistsCache[candidate]! ? candidate : null);
      return;
    }

    rootBundle.load(candidate).then((_) {
      _assetExistsCache[candidate] = true;
      if (mounted) setState(() => _confirmedAsset = candidate);
    }).catchError((_) {
      _assetExistsCache[candidate] = false;
      if (mounted) setState(() => _confirmedAsset = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = resolveGradient(widget.wmoCode, widget.localTime);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_confirmedAsset != null)
          Image.asset(_confirmedAsset!, fit: BoxFit.cover)
        else
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(gradient: gradient),
          ),
        Container(color: Colors.black.withAlpha(80)),
        widget.child,
      ],
    );
  }
}
