# CrispWeather

A clean, fast Flutter weather app powered by the free [Open-Meteo](https://open-meteo.com) API — no API key required.

---

## Features

### Current conditions
- Temperature, feels-like, humidity, wind speed & direction
- Hi / lo for the day, timestamp
- Dynamic animated background (sun rays, rain, snow, stars, fog, lightning) that reacts to live weather
- Weather alert banner for severe conditions (thunderstorm, violent rain, heavy snow…)

### Hourly forecast (24 h)
- Scrollable chart with smooth temperature curve
- Auto-scrolls to the current hour on load with a "now" marker line
- Precipitation bars with probability % and quantity mm stacked per column

### 7-day forecast
- Temperature max/min curves with labels below each dot
- Precipitation bars + mm quantity + dominant wind speed per day
- **Tap any day** → full hourly detail sheet for that day

### Detail stats
- Sunrise / sunset arc with live sun position
- Moon phase with pure Dart Julian Day calculation (no API needed)
- UV index gradient bar
- Wind compass rose
- Dew point, pressure, visibility, humidity tiles

### Activities
- Contextual activity suggestions based on weather code + temperature
- Press-to-dim glass cards

---

## Settings

| Option | Choices |
|---|---|
| Temperature | °C · °F |
| Wind speed | km/h · mph · m/s |
| Text size | Small · Normal · Large · Extra Large |
| Language | 12 languages, auto-detected from device |

Languages: English · Français · العربية · Español · Deutsch · Italiano · Português · 中文 · 日本語 · Türkçe · Русский · Nederlands

---

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3 / Dart |
| State | Provider + ChangeNotifier |
| Weather API | Open-Meteo (free, no key) |
| Localization | easy_localization + JSON |
| Storage | shared_preferences |
| Location | geolocator |

---

## Architecture

```
lib/
├── core/
│   ├── models/          # CurrentWeather, DailyForecast, HourlyForecast, City
│   ├── settings/        # SettingsProvider — temp unit, wind unit, text size
│   └── errors/          # WeatherException
├── data/
│   ├── services/        # WeatherService — HTTP with retry backoff
│   └── adapters/        # open_meteo_adapter — JSON → models
├── features/
│   ├── home/            # HomeScreen, HomeProvider, all home widgets
│   ├── forecast/        # DailyChart, DailyRow, DailyDetailSheet
│   ├── cities/          # CitiesScreen, CitiesProvider, city search
│   └── activities/      # Activity suggestion engine
└── shared/
    ├── theme/           # WeatherBackground, animated painters, panel system
    └── widgets/         # ForecastPanel, WeatherIcon, ShimmerLoader
```

---

## Background image system

The animated particle system (gradient + rain / snow / stars / fog / lightning) runs by default. A photo layer is wired and ready — drop JPEG files into `assets/images/` to activate:

| File | Scene |
|---|---|
| `bg_sunny_day.jpg` | Clear sky day |
| `bg_cloudy_day.jpg` | Overcast day |
| `bg_rainy.jpg` | Rain |
| `bg_snowy.jpg` | Snow |
| `bg_stormy.jpg` | Thunderstorm |
| `bg_night_clear.jpg` | Clear night |
| `bg_night_cloudy.jpg` | Cloudy night |
| `bg_foggy.jpg` | Fog |

Images composite at 55% opacity over the gradient so animated particles remain visible on top.

---

## Getting started

```bash
flutter pub get
flutter run
```

No API key, no account, no setup required.

---

## Data source

Weather data from **Open-Meteo** — free for non-commercial use, no registration required.
[open-meteo.com](https://open-meteo.com)
