import 'animated_weather_painter.dart' show WeatherScene;

String weatherBackgroundAsset(WeatherScene scene) => switch (scene) {
      WeatherScene.sunnyDay    => 'assets/images/bg_sunny_day.jpg',
      WeatherScene.cloudyDay   => 'assets/images/bg_cloudy_day.jpg',
      WeatherScene.rainy       => 'assets/images/bg_rainy.jpg',
      WeatherScene.snowy       => 'assets/images/bg_snowy.jpg',
      WeatherScene.stormy      => 'assets/images/bg_stormy.jpg',
      WeatherScene.nightClear  => 'assets/images/bg_night_clear.jpg',
      WeatherScene.nightCloudy => 'assets/images/bg_night_cloudy.jpg',
      WeatherScene.foggy       => 'assets/images/bg_foggy.jpg',
    };
