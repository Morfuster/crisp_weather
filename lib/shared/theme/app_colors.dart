import 'package:flutter/material.dart';

abstract final class AppColors {
  // Sunny day
  static const Color sunnyTop = Color(0xFF4A90D9);
  static const Color sunnyBottom = Color(0xFF87CEEB);

  // Cloudy day
  static const Color cloudyTop = Color(0xFF6B7B8D);
  static const Color cloudyBottom = Color(0xFF9BAAB8);

  // Rainy
  static const Color rainyTop = Color(0xFF3A4A5C);
  static const Color rainyBottom = Color(0xFF5A6E84);

  // Thunderstorm
  static const Color stormTop = Color(0xFF1A2535);
  static const Color stormBottom = Color(0xFF2E3F54);

  // Snowy
  static const Color snowyTop = Color(0xFF8EA8C3);
  static const Color snowyBottom = Color(0xFFB8D0E8);

  // Night clear
  static const Color nightTop = Color(0xFF0B1120);
  static const Color nightBottom = Color(0xFF1A2744);

  // Night cloudy
  static const Color nightCloudyTop = Color(0xFF1C2333);
  static const Color nightCloudyBottom = Color(0xFF2C3548);

  // Glass card
  static const Color glassWhite = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassWhiteDark = Color(0x14FFFFFF);

  // Overcast-style panel (light semi-opaque white)
  static const Color panelFill = Color(0x33FFFFFF);
  static const Color panelBorder = Color(0x22FFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textTertiary = Color(0x99FFFFFF);

  // Accent
  static const Color accentBlue = Color(0xFF00B4D8);
  static const Color accentYellow = Color(0xFFFFD60A);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentGreen = Color(0xFF34C759);

  // AQI colors
  static const Color aqiGood = Color(0xFF34C759);
  static const Color aqiModerate = Color(0xFFFFD60A);
  static const Color aqiSensitive = Color(0xFFFF9500);
  static const Color aqiUnhealthy = Color(0xFFFF3B30);
  static const Color aqiVeryUnhealthy = Color(0xFF8B008B);
  static const Color aqiHazardous = Color(0xFF7B0000);

  // UV colors
  static const Color uvLow = Color(0xFF34C759);
  static const Color uvModerate = Color(0xFFFFD60A);
  static const Color uvHigh = Color(0xFFFF9500);
  static const Color uvVeryHigh = Color(0xFFFF3B30);
  static const Color uvExtreme = Color(0xFF8B008B);
}
