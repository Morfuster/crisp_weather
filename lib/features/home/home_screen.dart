import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/settings/settings_provider.dart';
import '../../features/activities/activity_rules.dart';
import '../../shared/widgets/forecast_panel.dart';
import '../../shared/widgets/shimmer_loader.dart';
import '../../shared/theme/app_colors.dart';
import '../cities/cities_provider.dart';
import '../forecast/widgets/daily_chart.dart';
import 'home_provider.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/hourly_chart.dart';
import 'widgets/sunrise_sunset_card.dart';
import 'widgets/weather_background.dart';
import 'widgets/weather_stats_grid.dart';

const _supportedLocales = [
  Locale('en'), Locale('fr'), Locale('ar'), Locale('es'), Locale('de'),
  Locale('it'), Locale('pt'), Locale('zh'), Locale('ja'), Locale('tr'),
  Locale('ru'), Locale('nl'),
];

const _languageNames = {
  'en': 'English', 'fr': 'Français', 'ar': 'العربية', 'es': 'Español',
  'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'zh': '中文',
  'ja': '日本語', 'tr': 'Türkçe', 'ru': 'Русский', 'nl': 'Nederlands',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().refresh();
    });
  }

  void _showSettings() {
    final ctx = context;
    final currentCode = ctx.locale.languageCode;
    final screenH = MediaQuery.of(ctx).size.height;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A2744),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenH * 0.82),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text('textSize'.tr(),
                      style: Theme.of(ctx).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<SettingsProvider>(
                    builder: (c, settings, _) => SegmentedButton<TextSizeOption>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        selectedBackgroundColor: const Color(0xFF00B4D8),
                        selectedForegroundColor: Colors.white,
                        foregroundColor: Colors.white70,
                      ),
                      segments: TextSizeOption.values
                          .map((opt) => ButtonSegment<TextSizeOption>(
                                value: opt,
                                label: Text(opt.label,
                                    style: const TextStyle(fontSize: 11)),
                              ))
                          .toList(),
                      selected: {settings.textSize},
                      onSelectionChanged: (sel) =>
                          ctx.read<SettingsProvider>().setTextSize(sel.first),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('language'.tr(),
                      style: Theme.of(ctx).textTheme.titleMedium),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone_android_rounded,
                            color: Colors.white70),
                        title: Text('langSystem'.tr(),
                            style: const TextStyle(color: Colors.white)),
                        trailing: currentCode == ctx.deviceLocale.languageCode
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF00B4D8))
                            : null,
                        onTap: () {
                          ctx.resetLocale();
                          Navigator.pop(sheetCtx);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      ..._supportedLocales.map((locale) {
                        final code = locale.languageCode;
                        final isSelected = currentCode == code;
                        return ListTile(
                          title: Text(_languageNames[code] ?? code,
                              style: const TextStyle(color: Colors.white)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF00B4D8))
                              : null,
                          onTap: () {
                            ctx.setLocale(locale);
                            Navigator.pop(sheetCtx);
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final citiesProvider = context.watch<CitiesProvider>();
    final data = homeProvider.data;
    final now = DateTime.now();
    final wmoCode = data?.current.weatherCode ?? 0;

    return WeatherBackground(
      wmoCode: wmoCode,
      localTime: now,
      child: SafeArea(
        child: Column(
          children: [
            _AppBar(
              cityName: citiesProvider.activeCity?.name ?? '—',
              onSettings: _showSettings,
            ),
            Expanded(
              child: homeProvider.loading
                  ? _LoadingView()
                  : homeProvider.error != null
                      ? _ErrorView(
                          message: homeProvider.error!.message,
                          onRetry: () => context.read<HomeProvider>().refresh(),
                        )
                      : data != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  CurrentWeatherCard(
                                    weather: data.current,
                                    today: data.daily.first,
                                  ),
                                  const SizedBox(height: 16),
                                  if (data.hourly.isNotEmpty)
                                    HourlyChart(hourly: data.hourly),
                                  const SizedBox(height: 24),
                                  _SectionHeader(title: 'forecast7day'.tr()),
                                  DailyChart(daily: data.daily),
                                  const SizedBox(height: 24),
                                  _SectionHeader(title: 'activitiesToday'.tr()),
                                  _ActivitiesWrap(
                                    wmoCode: data.current.weatherCode,
                                    temperature: data.current.temperature,
                                  ),
                                  const SizedBox(height: 24),
                                  _SectionHeader(title: 'statsTitle'.tr()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: SunriseSunsetCard(
                                      sunrise: data.daily.first.sunrise,
                                      sunset: data.daily.first.sunset,
                                      now: now,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  WeatherStatsGrid(weather: data.current),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.cityName, required this.onSettings});

  final String cityName;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              cityName,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<HomeProvider>().refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class _ActivitiesWrap extends StatelessWidget {
  const _ActivitiesWrap({required this.wmoCode, required this.temperature});

  final int wmoCode;
  final double temperature;

  @override
  Widget build(BuildContext context) {
    final activities = suggestActivities(wmoCode, temperature);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: activities.map((a) => _ActivityCard(activity: a)).toList(),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
    return SizedBox(
      width: cardWidth,
      child: ForecastPanel(
        pressable: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activity.icon, size: 32, color: AppColors.accentBlue),
            const SizedBox(height: 8),
            Text(
              activity.labelKey.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              activity.reasonKey.tr(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          ShimmerLoader(width: double.infinity, height: 200),
          SizedBox(height: 16),
          ShimmerLoader(width: double.infinity, height: 100),
          SizedBox(height: 16),
          ShimmerLoader(width: double.infinity, height: 260),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(message,
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}
