String? resolveBackgroundAsset(int wmoCode, DateTime localTime) {
  final hour = localTime.hour;
  final isNight = hour < 6 || hour >= 20;

  if (isNight) {
    if (wmoCode == 2 || wmoCode == 3 || wmoCode >= 45) {
      return 'assets/images/bg_night_cloudy.jpg';
    }
    return 'assets/images/bg_night_clear.jpg';
  }

  if (wmoCode == 0 || wmoCode == 1) return 'assets/images/bg_sunny_day.jpg';
  if (wmoCode == 2 || wmoCode == 3) return 'assets/images/bg_cloudy_day.jpg';
  if (wmoCode == 45 || wmoCode == 48) return 'assets/images/bg_foggy.jpg';
  if ((wmoCode >= 51 && wmoCode <= 67) || (wmoCode >= 80 && wmoCode <= 82)) {
    return 'assets/images/bg_rainy.jpg';
  }
  if ((wmoCode >= 71 && wmoCode <= 77) || wmoCode == 85 || wmoCode == 86) {
    return 'assets/images/bg_snowy.jpg';
  }
  if (wmoCode == 95 || wmoCode == 96 || wmoCode == 99) {
    return 'assets/images/bg_storm.jpg';
  }
  return 'assets/images/bg_sunny_day.jpg';
}
