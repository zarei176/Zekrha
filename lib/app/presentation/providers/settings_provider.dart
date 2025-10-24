import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // کلیدهای SharedPreferences
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _fontSizeKey = 'font_size';
  static const String _autoBackupKey = 'auto_backup';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _reminderTimeKey = 'reminder_time';
  static const String _languageKey = 'language';
  static const String _showArabicKey = 'show_arabic';
  static const String _showTranslationKey = 'show_translation';
  static const String _showMeaningKey = 'show_meaning';
  
  // تنظیمات پیش‌فرض
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  double _fontSize = 16.0;
  bool _autoBackup = false;
  int _dailyGoal = 100;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  String _language = 'fa';
  bool _showArabic = true;
  bool _showTranslation = true;
  bool _showMeaning = true;
  
  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  double get fontSize => _fontSize;
  bool get autoBackup => _autoBackup;
  int get dailyGoal => _dailyGoal;
  TimeOfDay get reminderTime => _reminderTime;
  String get language => _language;
  bool get showArabic => _showArabic;
  bool get showTranslation => _showTranslation;
  bool get showMeaning => _showMeaning;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  // بارگذاری تنظیمات از SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
      _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;
      _autoBackup = prefs.getBool(_autoBackupKey) ?? false;
      _dailyGoal = prefs.getInt(_dailyGoalKey) ?? 100;
      _language = prefs.getString(_languageKey) ?? 'fa';
      _showArabic = prefs.getBool(_showArabicKey) ?? true;
      _showTranslation = prefs.getBool(_showTranslationKey) ?? true;
      _showMeaning = prefs.getBool(_showMeaningKey) ?? true;
      
      // بارگذاری زمان یادآوری
      final reminderHour = prefs.getInt('${_reminderTimeKey}_hour') ?? 8;
      final reminderMinute = prefs.getInt('${_reminderTimeKey}_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری تنظیمات: $e');
    }
  }
  
  // ذخیره تنظیمات در SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
      await prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
      await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
      await prefs.setDouble(_fontSizeKey, _fontSize);
      await prefs.setBool(_autoBackupKey, _autoBackup);
      await prefs.setInt(_dailyGoalKey, _dailyGoal);
      await prefs.setString(_languageKey, _language);
      await prefs.setBool(_showArabicKey, _showArabic);
      await prefs.setBool(_showTranslationKey, _showTranslation);
      await prefs.setBool(_showMeaningKey, _showMeaning);
      
      // ذخیره زمان یادآوری
      await prefs.setInt('${_reminderTimeKey}_hour', _reminderTime.hour);
      await prefs.setInt('${_reminderTimeKey}_minute', _reminderTime.minute);
    } catch (e) {
      debugPrint('خطا در ذخیره تنظیمات: $e');
    }
  }
  
  // تنظیم صدا
  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled != enabled) {
      _soundEnabled = enabled;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم لرزش
  Future<void> setVibrationEnabled(bool enabled) async {
    if (_vibrationEnabled != enabled) {
      _vibrationEnabled = enabled;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم اعلان‌ها
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم اندازه فونت
  Future<void> setFontSize(double size) async {
    final clampedSize = size.clamp(12.0, 24.0);
    if (_fontSize != clampedSize) {
      _fontSize = clampedSize;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم پشتیبان‌گیری خودکار
  Future<void> setAutoBackup(bool enabled) async {
    if (_autoBackup != enabled) {
      _autoBackup = enabled;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم هدف روزانه
  Future<void> setDailyGoal(int goal) async {
    final clampedGoal = goal.clamp(1, 1000);
    if (_dailyGoal != clampedGoal) {
      _dailyGoal = clampedGoal;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم زمان یادآوری
  Future<void> setReminderTime(TimeOfDay time) async {
    if (_reminderTime != time) {
      _reminderTime = time;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم زبان
  Future<void> setLanguage(String languageCode) async {
    if (_language != languageCode) {
      _language = languageCode;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم نمایش متن عربی
  Future<void> setShowArabic(bool show) async {
    if (_showArabic != show) {
      _showArabic = show;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم نمایش ترجمه
  Future<void> setShowTranslation(bool show) async {
    if (_showTranslation != show) {
      _showTranslation = show;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // تنظیم نمایش معنی
  Future<void> setShowMeaning(bool show) async {
    if (_showMeaning != show) {
      _showMeaning = show;
      notifyListeners();
      await _saveSettings();
    }
  }
  
  // بازنشانی تنظیمات به حالت پیش‌فرض
  Future<void> resetToDefaults() async {
    _soundEnabled = true;
    _vibrationEnabled = true;
    _notificationsEnabled = true;
    _fontSize = 16.0;
    _autoBackup = false;
    _dailyGoal = 100;
    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
    _language = 'fa';
    _showArabic = true;
    _showTranslation = true;
    _showMeaning = true;
    
    notifyListeners();
    await _saveSettings();
  }
  
  // دریافت تنظیمات به صورت Map
  Map<String, dynamic> toMap() {
    return {
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'fontSize': _fontSize,
      'autoBackup': _autoBackup,
      'dailyGoal': _dailyGoal,
      'reminderTime': {
        'hour': _reminderTime.hour,
        'minute': _reminderTime.minute,
      },
      'language': _language,
      'showArabic': _showArabic,
      'showTranslation': _showTranslation,
      'showMeaning': _showMeaning,
    };
  }
  
  // بارگذاری تنظیمات از Map
  Future<void> fromMap(Map<String, dynamic> map) async {
    _soundEnabled = (map['soundEnabled'] as bool?) ?? true;
    _vibrationEnabled = (map['vibrationEnabled'] as bool?) ?? true;
    _notificationsEnabled = (map['notificationsEnabled'] as bool?) ?? true;
    _fontSize = ((map['fontSize'] as num?) ?? 16.0).toDouble();
    _autoBackup = (map['autoBackup'] as bool?) ?? false;
    _dailyGoal = (map['dailyGoal'] as int?) ?? 100;
    _language = (map['language'] as String?) ?? 'fa';
    _showArabic = (map['showArabic'] as bool?) ?? true;
    _showTranslation = (map['showTranslation'] as bool?) ?? true;
    _showMeaning = (map['showMeaning'] as bool?) ?? true;
    
    if (map['reminderTime'] != null) {
      final reminderMap = map['reminderTime'] as Map<String, dynamic>;
      _reminderTime = TimeOfDay(
        hour: (reminderMap['hour'] as int?) ?? 8,
        minute: (reminderMap['minute'] as int?) ?? 0,
      );
    }
    
    notifyListeners();
    await _saveSettings();
  }
  
  // دریافت نام زبان
  String get languageName {
    switch (_language) {
      case 'fa':
        return 'فارسی';
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'فارسی';
    }
  }
  
  // دریافت زمان یادآوری به صورت رشته
  String get reminderTimeString {
    final hour = _reminderTime.hour.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}