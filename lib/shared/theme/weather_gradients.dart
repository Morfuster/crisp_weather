import 'package:flutter/material.dart';

import 'app_colors.dart';

LinearGradient resolveGradient(int wmoCode, DateTime localTime) {
  final hour = localTime.hour;
  final isNight = hour < 6 || hour >= 20;

  if (isNight) {
    return _nightGradient(wmoCode);
  }
  return _dayGradient(wmoCode);
}

LinearGradient _dayGradient(int code) {
  if (code == 0 || code == 1) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.sunnyTop, AppColors.sunnyBottom],
    );
  }
  if (code == 2 || code == 3 || code == 45 || code == 48) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.cloudyTop, AppColors.cloudyBottom],
    );
  }
  if (code >= 51 && code <= 67 || code >= 80 && code <= 82) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.rainyTop, AppColors.rainyBottom],
    );
  }
  if (code >= 71 && code <= 77 || code == 85 || code == 86) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.snowyTop, AppColors.snowyBottom],
    );
  }
  if (code == 95 || code == 96 || code == 99) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.stormTop, AppColors.stormBottom],
    );
  }
  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.sunnyTop, AppColors.sunnyBottom],
  );
}

LinearGradient _nightGradient(int code) {
  if (code == 2 || code == 3 || code >= 45) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.nightCloudyTop, AppColors.nightCloudyBottom],
    );
  }
  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.nightTop, AppColors.nightBottom],
  );
}
