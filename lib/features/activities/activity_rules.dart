import 'package:flutter/material.dart';

class Activity {
  const Activity({
    required this.labelKey,
    required this.icon,
    required this.reasonKey,
  });

  final String labelKey;
  final IconData icon;
  final String reasonKey;
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
        labelKey: 'stayIndoors',
        icon: Icons.home_rounded,
        reasonKey: 'stayIndoorsReason',
      ),
      Activity(
        labelKey: 'readBook',
        icon: Icons.menu_book_rounded,
        reasonKey: 'readBookReason',
      ),
      Activity(
        labelKey: 'watchMovie',
        icon: Icons.movie_rounded,
        reasonKey: 'watchMovieReason',
      ),
    ];
  }

  if (isRainy) {
    return const [
      Activity(
        labelKey: 'visitMuseum',
        icon: Icons.museum_rounded,
        reasonKey: 'visitMuseumReason',
      ),
      Activity(
        labelKey: 'cookAtHome',
        icon: Icons.soup_kitchen_rounded,
        reasonKey: 'cookAtHomeReason',
      ),
      Activity(
        labelKey: 'indoorWorkout',
        icon: Icons.fitness_center_rounded,
        reasonKey: 'indoorWorkoutReason',
      ),
    ];
  }

  if (isSnowy) {
    return const [
      Activity(
        labelKey: 'skiing',
        icon: Icons.downhill_skiing_rounded,
        reasonKey: 'skiingReason',
      ),
      Activity(
        labelKey: 'buildSnowman',
        icon: Icons.ac_unit_rounded,
        reasonKey: 'buildSnowmanReason',
      ),
      Activity(
        labelKey: 'hotChocolate',
        icon: Icons.local_cafe_rounded,
        reasonKey: 'hotChocolateReason',
      ),
    ];
  }

  if (isClear && isHot) {
    return const [
      Activity(
        labelKey: 'swimming',
        icon: Icons.pool_rounded,
        reasonKey: 'swimmingReason',
      ),
      Activity(
        labelKey: 'picnic',
        icon: Icons.outdoor_grill_rounded,
        reasonKey: 'picnicReason',
      ),
      Activity(
        labelKey: 'stayHydrated',
        icon: Icons.water_drop_rounded,
        reasonKey: 'stayHydratedReason',
      ),
    ];
  }

  if (isClear && isWarm) {
    return const [
      Activity(
        labelKey: 'running',
        icon: Icons.directions_run_rounded,
        reasonKey: 'runningReason',
      ),
      Activity(
        labelKey: 'cycling',
        icon: Icons.directions_bike_rounded,
        reasonKey: 'cyclingReason',
      ),
      Activity(
        labelKey: 'picnic',
        icon: Icons.outdoor_grill_rounded,
        reasonKey: 'picnicSunnyReason',
      ),
      Activity(
        labelKey: 'photography',
        icon: Icons.camera_alt_rounded,
        reasonKey: 'photographyReason',
      ),
    ];
  }

  if (isCold) {
    return const [
      Activity(
        labelKey: 'cozyCafe',
        icon: Icons.local_cafe_rounded,
        reasonKey: 'cozyCafeReason',
      ),
      Activity(
        labelKey: 'indoorWorkout',
        icon: Icons.fitness_center_rounded,
        reasonKey: 'indoorWorkoutColdReason',
      ),
    ];
  }

  if (isPartlyCloudy && isWarm) {
    return const [
      Activity(
        labelKey: 'walking',
        icon: Icons.directions_walk_rounded,
        reasonKey: 'walkingReason',
      ),
      Activity(
        labelKey: 'cycling',
        icon: Icons.directions_bike_rounded,
        reasonKey: 'cyclingCloudyReason',
      ),
    ];
  }

  return const [
    Activity(
      labelKey: 'walking',
      icon: Icons.directions_walk_rounded,
      reasonKey: 'walkingDefaultReason',
    ),
    Activity(
      labelKey: 'readBook',
      icon: Icons.menu_book_rounded,
      reasonKey: 'readBookDefaultReason',
    ),
  ];
}
