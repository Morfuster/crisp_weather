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

class SettingsProvider extends ChangeNotifier {
  static const _textSizeKey = 'text_size_option';

  TextSizeOption _textSize = TextSizeOption.normal;
  TextSizeOption get textSize => _textSize;
  double get textScale => _textSize.scale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_textSizeKey) ?? TextSizeOption.normal.index;
    _textSize = TextSizeOption.values[index.clamp(0, TextSizeOption.values.length - 1)];
    notifyListeners();
  }

  Future<void> setTextSize(TextSizeOption option) async {
    if (_textSize == option) return;
    _textSize = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textSizeKey, option.index);
    notifyListeners();
  }
}
