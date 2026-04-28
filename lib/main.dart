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

const _supportedLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('ar'),
  Locale('es'),
  Locale('de'),
  Locale('it'),
  Locale('pt'),
  Locale('zh'),
  Locale('ja'),
  Locale('tr'),
  Locale('ru'),
  Locale('nl'),
];

const _languageNames = {
  'en': 'English',
  'fr': 'Français',
  'ar': 'العربية',
  'es': 'Español',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'zh': '中文',
  'ja': '日本語',
  'tr': 'Türkçe',
  'ru': 'Русский',
  'nl': 'Nederlands',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: _supportedLocales,
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
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: MaterialApp(
            title: 'CrispWeather',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const _AppStartup(),
          ),
        ),
      ),
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
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'settings',
        backgroundColor: Colors.black45,
        onPressed: () => _showSettings(context),
        child: const Icon(Icons.settings_rounded, color: Colors.white),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final currentCode = context.locale.languageCode;
    final screenH = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
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
                // — Text Size —
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'textSize'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<SettingsProvider>(
                    builder: (ctx, settings, child) => SegmentedButton<TextSizeOption>(
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
                      onSelectionChanged: (selected) =>
                          context.read<SettingsProvider>().setTextSize(selected.first),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                // — Language —
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'language'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                        trailing: currentCode == context.deviceLocale.languageCode
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF00B4D8))
                            : null,
                        onTap: () {
                          context.resetLocale();
                          Navigator.pop(sheetCtx);
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      ..._supportedLocales.map((locale) {
                        final code = locale.languageCode;
                        final name = _languageNames[code] ?? code;
                        final isSelected = currentCode == code;
                        return ListTile(
                          title: Text(name,
                              style: const TextStyle(color: Colors.white)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF00B4D8))
                              : null,
                          onTap: () {
                            context.setLocale(locale);
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
}
