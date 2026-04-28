import 'package:flutter/material.dart';

class Activity {
  const Activity({
    required this.label,
    required this.icon,
    required this.reason,
  });

  final String label;
  final IconData icon;
  final String reason;
}

List<Activity> suggestActivities(int wmoCode, double temperature) {
  final isClear = wmoCode <= 1;
  final isPartlyCloudy = wmoCode == 2 || wmoCode == 3;
  final isRainy = (wmoCode >= 51 && wmoCode <= 67) ||
      (wmoCode >= 80 && wmoCode <= 82);
  final isSnowy = (wmoCode >= 71 && wmoCode <= 77) ||
      wmoCode == 85 ||
      wmoCode == 86;
  final isStormy = wmoCode == 95 || wmoCode == 96 || wmoCode == 99;
  final isWarm = temperature >= 18;
  final isHot = temperature >= 28;
  final isCold = temperature < 5;

  if (isStormy) {
    return const [
      Activity(
        label: 'Stay indoors',
        icon: Icons.home_rounded,
        reason: 'Thunderstorm active — stay safe inside.',
      ),
      Activity(
        label: 'Read a book',
        icon: Icons.menu_book_rounded,
        reason: 'Perfect weather to curl up with a good book.',
      ),
      Activity(
        label: 'Watch a movie',
        icon: Icons.movie_rounded,
        reason: 'Great excuse to catch up on your watch list.',
      ),
    ];
  }

  if (isRainy) {
    return const [
      Activity(
        label: 'Visit a museum',
        icon: Icons.museum_rounded,
        reason: 'Stay dry and explore something cultural.',
      ),
      Activity(
        label: 'Cook at home',
        icon: Icons.soup_kitchen_rounded,
        reason: 'Rainy days are perfect for comfort food.',
      ),
      Activity(
        label: 'Indoor workout',
        icon: Icons.fitness_center_rounded,
        reason: 'Keep moving without the rain.',
      ),
    ];
  }

  if (isSnowy) {
    return const [
      Activity(
        label: 'Skiing',
        icon: Icons.downhill_skiing_rounded,
        reason: 'Fresh snow — great conditions for the slopes.',
      ),
      Activity(
        label: 'Build a snowman',
        icon: Icons.ac_unit_rounded,
        reason: 'Classic winter fun.',
      ),
      Activity(
        label: 'Hot chocolate',
        icon: Icons.local_cafe_rounded,
        reason: 'Warm up with a cozy drink.',
      ),
    ];
  }

  if (isClear && isHot) {
    return const [
      Activity(
        label: 'Swimming',
        icon: Icons.pool_rounded,
        reason: 'Hot clear day — perfect for a swim.',
      ),
      Activity(
        label: 'Picnic',
        icon: Icons.outdoor_grill_rounded,
        reason: 'Great weather for outdoor dining.',
      ),
      Activity(
        label: 'Stay hydrated',
        icon: Icons.water_drop_rounded,
        reason: 'Heat above 28°C — drink plenty of water.',
      ),
    ];
  }

  if (isClear && isWarm) {
    return const [
      Activity(
        label: 'Running',
        icon: Icons.directions_run_rounded,
        reason: 'Clear skies and good temperature for a run.',
      ),
      Activity(
        label: 'Cycling',
        icon: Icons.directions_bike_rounded,
        reason: 'Ideal conditions for a bike ride.',
      ),
      Activity(
        label: 'Picnic',
        icon: Icons.outdoor_grill_rounded,
        reason: 'Sunny day great for outdoor dining.',
      ),
      Activity(
        label: 'Photography',
        icon: Icons.camera_alt_rounded,
        reason: 'Beautiful light for photos.',
      ),
    ];
  }

  if (isCold) {
    return const [
      Activity(
        label: 'Cozy café',
        icon: Icons.local_cafe_rounded,
        reason: 'Cold outside — warm up with a hot drink.',
      ),
      Activity(
        label: 'Indoor workout',
        icon: Icons.fitness_center_rounded,
        reason: 'Stay warm and active inside.',
      ),
    ];
  }

  if (isPartlyCloudy && isWarm) {
    return const [
      Activity(
        label: 'Walking',
        icon: Icons.directions_walk_rounded,
        reason: 'Comfortable temperature for a stroll.',
      ),
      Activity(
        label: 'Cycling',
        icon: Icons.directions_bike_rounded,
        reason: 'Cloudy skies keep it cool for a ride.',
      ),
    ];
  }

  return const [
    Activity(
      label: 'Walking',
      icon: Icons.directions_walk_rounded,
      reason: 'A good day to get some fresh air.',
    ),
    Activity(
      label: 'Read a book',
      icon: Icons.menu_book_rounded,
      reason: 'Relaxed conditions for indoor downtime.',
    ),
  ];
}
