import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TextSizeOption { small, normal, large, extraLarge }

extension TextSizeOptionExt on TextSizeOption {
  double get scale => switch (this) {
        TextSizeOption.small => 0.85,
        TextSizeOption.normal => 1.0,
        TextSizeOption.large => 1.18,
        TextSizeOption.extraLarge => 1.38,
      };

  String get label => switch (this) {
        TextSizeOption.small => 'Small',
        TextSizeOption.normal => 'Normal',
        TextSizeOption.large => 'Large',
        TextSizeOption.extraLarge => 'Extra Large',
      };
}

enum TempUnit { celsius, fahrenheit }

extension TempUnitExt on TempUnit {
  String get label => switch (this) {
        TempUnit.celsius => '°C',
        TempUnit.fahrenheit => '°F',
      };

  double convert(double celsius) => switch (this) {
        TempUnit.celsius => celsius,
        TempUnit.fahrenheit => celsius * 9 / 5 + 32,
      };

  String format(double celsius) => '${convert(celsius).round()}°';
}

enum WindUnit { kmh, mph, ms }

extension WindUnitExt on WindUnit {
  String get label => switch (this) {
        WindUnit.kmh => 'km/h',
        WindUnit.mph => 'mph',
        WindUnit.ms => 'm/s',
      };

  double convert(double kmh) => switch (this) {
        WindUnit.kmh => kmh,
        WindUnit.mph => kmh * 0.621371,
        WindUnit.ms => kmh / 3.6,
      };

  String format(double kmh) {
    final v = convert(kmh);
    return switch (this) {
      WindUnit.ms => '${v.toStringAsFixed(1)} $label',
      _ => '${v.round()} $label',
    };
  }
}

class SettingsProvider extends ChangeNotifier {
  static const _textSizeKey = 'text_size_option';
  static const _tempUnitKey = 'temp_unit';
  static const _windUnitKey = 'wind_unit';

  TextSizeOption _textSize = TextSizeOption.normal;
  TempUnit _tempUnit = TempUnit.celsius;
  WindUnit _windUnit = WindUnit.kmh;

  TextSizeOption get textSize => _textSize;
  double get textScale => _textSize.scale;
  TempUnit get tempUnit => _tempUnit;
  WindUnit get windUnit => _windUnit;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final textIndex = prefs.getInt(_textSizeKey) ?? TextSizeOption.normal.index;
    _textSize = TextSizeOption.values[textIndex.clamp(0, TextSizeOption.values.length - 1)];

    final tempIndex = prefs.getInt(_tempUnitKey) ?? TempUnit.celsius.index;
    _tempUnit = TempUnit.values[tempIndex.clamp(0, TempUnit.values.length - 1)];

    final windIndex = prefs.getInt(_windUnitKey) ?? WindUnit.kmh.index;
    _windUnit = WindUnit.values[windIndex.clamp(0, WindUnit.values.length - 1)];

    notifyListeners();
  }

  Future<void> setTextSize(TextSizeOption option) async {
    if (_textSize == option) return;
    _textSize = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textSizeKey, option.index);
    notifyListeners();
  }

  Future<void> setTempUnit(TempUnit unit) async {
    if (_tempUnit == unit) return;
    _tempUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tempUnitKey, unit.index);
    notifyListeners();
  }

  Future<void> setWindUnit(WindUnit unit) async {
    if (_windUnit == unit) return;
    _windUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_windUnitKey, unit.index);
    notifyListeners();
  }
}
