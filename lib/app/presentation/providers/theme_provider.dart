import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode => !isDarkMode;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  // بارگذاری تم از SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری تم: $e');
    }
  }
  
  // ذخیره تم در SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      debugPrint('خطا در ذخیره تم: $e');
    }
  }
  
  // تغییر به تم روشن
  Future<void> setLightMode() async {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
      notifyListeners();
      await _saveThemeMode();
    }
  }
  
  // تغییر به تم تیره
  Future<void> setDarkMode() async {
    if (_themeMode != ThemeMode.dark) {
      _themeMode = ThemeMode.dark;
      notifyListeners();
      await _saveThemeMode();
    }
  }
  
  // تغییر به تم سیستم
  Future<void> setSystemMode() async {
    if (_themeMode != ThemeMode.system) {
      _themeMode = ThemeMode.system;
      notifyListeners();
      await _saveThemeMode();
    }
  }
  
  // تغییر تم (چرخشی)
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setDarkMode();
        break;
      case ThemeMode.dark:
        await setSystemMode();
        break;
      case ThemeMode.system:
        await setLightMode();
        break;
    }
  }
  
  // تنظیم تم بر اساس نام
  Future<void> setThemeByName(String themeName) async {
    switch (themeName.toLowerCase()) {
      case 'light':
      case 'روشن':
        await setLightMode();
        break;
      case 'dark':
      case 'تیره':
        await setDarkMode();
        break;
      case 'system':
      case 'سیستم':
        await setSystemMode();
        break;
      default:
        debugPrint('نام تم نامعتبر: $themeName');
    }
  }
  
  // دریافت نام تم فعلی
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'روشن';
      case ThemeMode.dark:
        return 'تیره';
      case ThemeMode.system:
        return 'سیستم';
    }
  }
  
  // دریافت آیکون تم فعلی
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  // لیست تمام تم‌های موجود
  List<Map<String, dynamic>> get availableThemes {
    return [
      {
        'name': 'روشن',
        'value': ThemeMode.light,
        'icon': Icons.light_mode,
        'description': 'تم روشن برای استفاده در روز',
      },
      {
        'name': 'تیره',
        'value': ThemeMode.dark,
        'icon': Icons.dark_mode,
        'description': 'تم تیره برای استفاده در شب',
      },
      {
        'name': 'سیستم',
        'value': ThemeMode.system,
        'icon': Icons.brightness_auto,
        'description': 'تنظیم خودکار بر اساس سیستم',
      },
    ];
  }
}