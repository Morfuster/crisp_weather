import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/settings/settings_provider.dart';
import 'data/services/geocoding_service.dart';
import 'data/services/weather_service.dart';
import 'features/cities/cities_provider.dart';
import 'features/cities/cities_screen.dart';
import 'features/home/home_provider.dart';
import 'features/home/home_screen.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), Locale('fr'), Locale('ar'), Locale('es'), Locale('de'),
        Locale('it'), Locale('pt'), Locale('zh'), Locale('ja'), Locale('tr'),
        Locale('ru'), Locale('nl'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const CrispWeatherApp(),
    ),
  );
}

class CrispWeatherApp extends StatelessWidget {
  const CrispWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final geocodingService = GeocodingService();
    final weatherService = WeatherService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => CitiesProvider(geocodingService: geocodingService),
        ),
        ChangeNotifierProxyProvider<CitiesProvider, HomeProvider>(
          create: (context) => HomeProvider(
            citiesProvider: context.read<CitiesProvider>(),
            weatherService: weatherService,
          ),
          update: (_, cities, previous) =>
              previous ??
              HomeProvider(
                citiesProvider: cities,
                weatherService: weatherService,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'CrispWeather',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const _TextScaleWrapper(child: _AppStartup()),
      ),
    );
  }
}

class _TextScaleWrapper extends StatelessWidget {
  const _TextScaleWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (ctx, settings, ch) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(textScaler: TextScaler.linear(settings.textScale)),
        child: ch!,
      ),
      child: child,
    );
  }
}

class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<SettingsProvider>().load(),
        context.read<CitiesProvider>().loadSavedCities(),
      ]);
      if (mounted) {
        await context.read<HomeProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const AppShell();
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    CitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.wb_sunny_outlined),
            activeIcon: const Icon(Icons.wb_sunny_rounded),
            label: 'tabWeather'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_city_outlined),
            activeIcon: const Icon(Icons.location_city_rounded),
            label: 'tabCities'.tr(),
          ),
        ],
      ),
    );
  }

}
