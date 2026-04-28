import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/activities/activity_rules.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loader.dart';
import '../../shared/theme/app_colors.dart';
import '../cities/cities_provider.dart';
import '../forecast/widgets/daily_row.dart';
import 'home_provider.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/hourly_scroll.dart';
import 'widgets/weather_background.dart';

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
            _AppBar(cityName: citiesProvider.activeCity?.name ?? '—'),
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
                                  CurrentWeatherCard(weather: data.current),
                                  const SizedBox(height: 16),
                                  if (data.hourly.isNotEmpty)
                                    HourlyScroll(hourly: data.hourly),
                                  const SizedBox(height: 24),
                                  _SectionHeader(title: 'forecast7day'.tr()),
                                  ...data.daily.map((d) => DailyRow(forecast: d)),
                                  const SizedBox(height: 24),
                                  _SectionHeader(title: 'activitiesToday'.tr()),
                                  _ActivitiesWrap(
                                    wmoCode: data.current.weatherCode,
                                    temperature: data.current.temperature,
                                  ),
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
  const _AppBar({required this.cityName});

  final String cityName;

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
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activity.icon, size: 32, color: AppColors.accentBlue),
            const SizedBox(height: 8),
            Text(
              activity.label,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              activity.reason,
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
