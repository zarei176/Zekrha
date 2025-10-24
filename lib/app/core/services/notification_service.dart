import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  
  // راه‌اندازی سرویس اعلان‌ها
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // تنظیمات Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // تنظیمات iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // تنظیمات کلی
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // راه‌اندازی
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _isInitialized = true;
      debugPrint('سرویس اعلان‌ها راه‌اندازی شد');
    } catch (e) {
      debugPrint('خطا در راه‌اندازی سرویس اعلان‌ها: $e');
    }
  }
  
  // درخواست مجوز (Android 13+)
  static Future<bool> requestPermission() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      
      return true; // iOS مجوز را در initialize درخواست می‌کند
    } catch (e) {
      debugPrint('خطا در درخواست مجوز اعلان: $e');
      return false;
    }
  }
  
  // نمایش اعلان فوری
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'instant_notifications',
        'اعلان‌های فوری',
        channelDescription: 'اعلان‌های فوری اپلیکیشن',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('خطا در نمایش اعلان فوری: $e');
    }
  }
  
  // برنامه‌ریزی اعلان (ساده شده)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      // فعلاً فقط اعلان فوری نمایش می‌دهیم
      await showInstantNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('خطا در برنامه‌ریزی اعلان: $e');
    }
  }
  
  // برنامه‌ریزی اعلان روزانه (ساده شده)
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    try {
      // فعلاً فقط اعلان فوری نمایش می‌دهیم
      await showInstantNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('خطا در برنامه‌ریزی اعلان روزانه: $e');
    }
  }
  
  // لغو اعلان خاص
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('خطا در لغو اعلان: $e');
    }
  }
  
  // لغو همه اعلان‌ها
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('خطا در لغو همه اعلان‌ها: $e');
    }
  }
  
  // دریافت اعلان‌های برنامه‌ریزی شده
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('خطا در دریافت اعلان‌های برنامه‌ریزی شده: $e');
      return [];
    }
  }
  
  // بررسی وجود اعلان برنامه‌ریزی شده
  static Future<bool> hasScheduledNotification(int id) async {
    try {
      final pending = await getPendingNotifications();
      return pending.any((notification) => notification.id == id);
    } catch (e) {
      debugPrint('خطا در بررسی اعلان برنامه‌ریزی شده: $e');
      return false;
    }
  }
  
  // اعلان تکمیل ذکر
  static Future<void> showCompletionNotification({
    required String dhikrName,
    required int count,
  }) async {
    await showInstantNotification(
      id: 1001,
      title: '🎉 تبریک!',
      body: 'شما $count بار "$dhikrName" را تکمیل کردید',
      payload: 'completion',
    );
  }
  
  // اعلان یادآوری روزانه
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    String? customMessage,
  }) async {
    // لغو یادآوری قبلی
    await cancelNotification(2001);
    
    // برنامه‌ریزی یادآوری جدید
    await scheduleDailyNotification(
      id: 2001,
      title: '🕌 وقت ذکر',
      body: customMessage ?? 'وقت انجام اذکار روزانه فرا رسیده است',
      time: time,
      payload: 'daily_reminder',
    );
  }
  
  // اعلان انگیزشی
  static Future<void> showMotivationalNotification() async {
    final messages = [
      'ذکر خدا آرامش قلب است 💚',
      'هر ذکری شما را به خدا نزدیک‌تر می‌کند 🤲',
      'ذکر نور دل و روح است ✨',
      'با ذکر، دل‌ها آرام می‌گیرد 🕊️',
      'ذکر خدا بهترین عبادت است 🌟',
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    
    await showInstantNotification(
      id: 3001,
      title: 'پیام انگیزشی',
      body: randomMessage,
      payload: 'motivational',
    );
  }
  
  // اعلان آمار هفتگی
  static Future<void> showWeeklyStats({
    required int totalCount,
    required int streakDays,
  }) async {
    await showInstantNotification(
      id: 4001,
      title: '📊 آمار هفتگی شما',
      body: 'این هفته $totalCount ذکر انجام دادید. رکورد مداومت: $streakDays روز',
      payload: 'weekly_stats',
    );
  }
  
  
  // مدیریت کلیک روی اعلان
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      debugPrint('اعلان کلیک شد: $payload');
      
      // اینجا می‌توان بر اساس payload عملیات مختلف انجام داد
      switch (payload) {
        case 'completion':
          // نمایش صفحه آمار یا تبریک
          break;
        case 'daily_reminder':
          // باز کردن صفحه اصلی برای شروع ذکر
          break;
        case 'motivational':
          // نمایش پیام‌های انگیزشی بیشتر
          break;
        case 'weekly_stats':
          // نمایش صفحه آمار تفصیلی
          break;
      }
    } catch (e) {
      debugPrint('خطا در مدیریت کلیک اعلان: $e');
    }
  }
  
  // تنظیم یادآوری‌های هوشمند
  static Future<void> setupSmartReminders({
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
  }) async {
    // یادآوری صبح
    await scheduleDailyNotification(
      id: 5001,
      title: '🌅 صبح بخیر',
      body: 'روز خود را با ذکر خدا آغاز کنید',
      time: morningTime,
      payload: 'morning_reminder',
    );
    
    // یادآوری عصر
    await scheduleDailyNotification(
      id: 5002,
      title: '🌆 عصر بخیر',
      body: 'وقت ذکر و دعا فرا رسیده است',
      time: eveningTime,
      payload: 'evening_reminder',
    );
  }
  
  // لغو یادآوری‌های هوشمند
  static Future<void> cancelSmartReminders() async {
    await cancelNotification(5001); // صبح
    await cancelNotification(5002); // عصر
  }
}