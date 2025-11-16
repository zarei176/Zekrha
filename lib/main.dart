import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/core/services/duration_adapter.dart';
import 'app/core/services/notification_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/models/dhikr_model.dart';
import 'app/data/models/dhikr_session_model.dart';
import 'app/presentation/providers/dhikr_provider.dart';
import 'app/presentation/providers/theme_provider.dart';
import 'app/presentation/providers/settings_provider.dart';
import 'app/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تنظیم جهت RTL برای زبان فارسی
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // راه‌اندازی Hive
  await Hive.initFlutter();
  
  // ثبت آداپترهای Hive
  Hive.registerAdapter(DhikrModelAdapter());
  Hive.registerAdapter(DhikrSessionModelAdapter());
  Hive.registerAdapter(DurationAdapter());
  
  // باز کردن جعبه‌های Hive
  await Hive.openBox<DhikrModel>('dhikrs');
  await Hive.openBox<DhikrSessionModel>('sessions');
  await Hive.openBox('settings');
  
  // راه‌اندازی سرویس اعلان‌ها
  await NotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DhikrProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ذکرهای من',
            debugShowCheckedModeBanner: false,
            
            // تم‌ها
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // پشتیبانی از RTL
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'), // فارسی
              Locale('ar', 'SA'), // عربی
              Locale('en', 'US'), // انگلیسی
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // صفحه اصلی
            home: const HomePage(),
            
            // مسیرها
            routes: {
              '/home': (context) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}