import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:vibration/vibration.dart';

import '../../data/models/dhikr_model.dart';
import '../../data/models/dhikr_session_model.dart';

class DhikrProvider extends ChangeNotifier {
  // جعبه‌های Hive
  late Box<DhikrModel> _dhikrBox;
  late Box<DhikrSessionModel> _sessionBox;
  
  // وضعیت فعلی
  DhikrModel? _currentDhikr;
  DhikrSessionModel? _currentSession;
  bool _isCountingActive = false;
  int _currentCount = 0;
  int _targetCount = 33;
  DateTime? _sessionStartTime;
  
  // لیست اذکار
  List<DhikrModel> _dhikrs = [];
  List<DhikrModel> _favoriteDhikrs = [];
  List<DhikrSessionModel> _recentSessions = [];
  
  // فیلتر و جستجو
  String _searchQuery = '';
  String _selectedCategory = 'همه';
  List<String> _categories = ['همه'];
  
  // آمار
  int _todayCount = 0;
  int _weekCount = 0;
  int _monthCount = 0;
  int _totalCount = 0;
  int _streakDays = 0;
  
  // Getters
  DhikrModel? get currentDhikr => _currentDhikr;
  DhikrSessionModel? get currentSession => _currentSession;
  bool get isCountingActive => _isCountingActive;
  int get currentCount => _currentCount;
  int get targetCount => _targetCount;
  DateTime? get sessionStartTime => _sessionStartTime;
  
  List<DhikrModel> get dhikrs => _dhikrs;
  List<DhikrModel> get favoriteDhikrs => _favoriteDhikrs;
  List<DhikrSessionModel> get recentSessions => _recentSessions;
  
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;
  
  int get todayCount => _todayCount;
  int get weekCount => _weekCount;
  int get monthCount => _monthCount;
  int get totalCount => _totalCount;
  int get streakDays => _streakDays;
  
  // درصد پیشرفت
  double get progressPercentage {
    if (_targetCount == 0) return 0.0;
    return (_currentCount / _targetCount).clamp(0.0, 1.0);
  }
  
  // باقی‌مانده تا هدف
  int get remainingCount {
    return (_targetCount - _currentCount).clamp(0, _targetCount);
  }
  
  // وضعیت تکمیل
  bool get isCompleted => _currentCount >= _targetCount;
  
  DhikrProvider() {
    _initializeBoxes();
  }
  
  // راه‌اندازی جعبه‌های Hive
  Future<void> _initializeBoxes() async {
    try {
      _dhikrBox = Hive.box<DhikrModel>('dhikrs');
      _sessionBox = Hive.box<DhikrSessionModel>('sessions');
      
      await _loadInitialData();
      await _calculateStatistics();
    } catch (e) {
      debugPrint('خطا در راه‌اندازی جعبه‌ها: $e');
    }
  }
  
  // بارگذاری داده‌های اولیه
  Future<void> _loadInitialData() async {
    try {
      // بارگذاری اذکار
      _dhikrs = _dhikrBox.values.toList();
      
      // اگر هیچ ذکری وجود ندارد، اذکار پیش‌فرض را اضافه کن
      if (_dhikrs.isEmpty) {
        await _addDefaultDhikrs();
      }
      
      // بارگذاری اذکار مورد علاقه
      _favoriteDhikrs = _dhikrs.where((dhikr) => dhikr.isFavorite).toList();
      
      // بارگذاری جلسات اخیر
      _recentSessions = _sessionBox.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      
      // بارگذاری دسته‌بندی‌ها
      _updateCategories();
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بارگذاری داده‌های اولیه: $e');
    }
  }
  
  // اضافه کردن اذکار پیش‌فرض
  Future<void> _addDefaultDhikrs() async {
    final defaultDhikrs = [
      // تسبیحات اصلی
      DhikrModel(
        id: 'subhan_allah',
        arabicText: 'سُبْحَانَ اللَّهِ',
        persianTranslation: 'سبحان الله',
        meaning: 'خدا منزه و پاک است',
        category: 'تسبیحات',
        defaultCount: 33,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['تسبیح', 'ذکر', 'پاکی'],
        priority: 1,
      ),
      DhikrModel(
        id: 'alhamdulillah',
        arabicText: 'الْحَمْدُ لِلَّهِ',
        persianTranslation: 'الحمدلله',
        meaning: 'ستایش مخصوص خداست',
        category: 'تسبیحات',
        defaultCount: 33,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['حمد', 'ذکر', 'شکر'],
        priority: 2,
      ),
      DhikrModel(
        id: 'allahu_akbar',
        arabicText: 'اللَّهُ أَكْبَرُ',
        persianTranslation: 'الله اکبر',
        meaning: 'خدا بزرگ‌تر است',
        category: 'تسبیحات',
        defaultCount: 34,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['تکبیر', 'ذکر', 'بزرگی'],
        priority: 3,
      ),
      DhikrModel(
        id: 'la_ilaha_illa_allah',
        arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
        persianTranslation: 'لا اله الا الله',
        meaning: 'هیچ معبودی جز خدا نیست',
        category: 'کلمه طیبه',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['توحید', 'کلمه', 'ایمان'],
        priority: 4,
      ),
      DhikrModel(
        id: 'istighfar',
        arabicText: 'أَسْتَغْفِرُ اللَّهَ',
        persianTranslation: 'استغفرالله',
        meaning: 'از خدا آمرزش می‌طلبم',
        category: 'استغفار',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['استغفار', 'توبه', 'آمرزش'],
        priority: 5,
      ),
      
      // صلوات
      DhikrModel(
        id: 'salawat',
        arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ',
        persianTranslation: 'اللهم صل علی محمد و آل محمد',
        meaning: 'خدایا بر محمد و آل محمد درود فرست',
        category: 'صلوات',
        defaultCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['صلوات', 'درود', 'پیامبر'],
        priority: 6,
      ),
      DhikrModel(
        id: 'salawat_complete',
        arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَعَجِّلْ فَرَجَهُمْ',
        persianTranslation: 'اللهم صل علی محمد و آل محمد و عجل فرجهم',
        meaning: 'خدایا بر محمد و آل محمد درود فرست و فرج آنان را نزدیک گردان',
        category: 'صلوات',
        defaultCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['صلوات', 'درود', 'فرج', 'امام زمان'],
        priority: 7,
      ),
      
      // ذکرهای صحیح ایام هفته (بر اساس منابع اسلامی معتبر)
      DhikrModel(
        id: 'saturday_dhikr',
        arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
        persianTranslation: 'لا اله الا الله',
        meaning: 'هیچ معبودی جز خدا نیست',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['شنبه', 'ایام هفته', 'توحید'],
        priority: 8,
      ),
      DhikrModel(
        id: 'sunday_dhikr',
        arabicText: 'سُبْحَانَ اللَّهِ',
        persianTranslation: 'سبحان الله',
        meaning: 'خدا منزه و پاک است',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['یکشنبه', 'ایام هفته', 'تسبیح'],
        priority: 9,
      ),
      DhikrModel(
        id: 'monday_dhikr',
        arabicText: 'الْحَمْدُ لِلَّهِ',
        persianTranslation: 'الحمدلله',
        meaning: 'ستایش مخصوص خداست',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['دوشنبه', 'ایام هفته', 'حمد'],
        priority: 10,
      ),
      DhikrModel(
        id: 'tuesday_dhikr',
        arabicText: 'اللَّهُ أَكْبَرُ',
        persianTranslation: 'الله اکبر',
        meaning: 'خدا بزرگ‌تر است',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['سه‌شنبه', 'ایام هفته', 'تکبیر'],
        priority: 11,
      ),
      DhikrModel(
        id: 'wednesday_dhikr',
        arabicText: 'أَسْتَغْفِرُ اللَّهَ',
        persianTranslation: 'استغفرالله',
        meaning: 'از خدا آمرزش می‌طلبم',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['چهارشنبه', 'ایام هفته', 'استغفار'],
        priority: 12,
      ),
      DhikrModel(
        id: 'thursday_dhikr',
        arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        persianTranslation: 'لا حول و لا قوة الا بالله',
        meaning: 'هیچ نیرو و قدرتی جز از جانب خدا نیست',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['پنج‌شنبه', 'ایام هفته', 'قدرت'],
        priority: 13,
      ),
      DhikrModel(
        id: 'friday_dhikr',
        arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ',
        persianTranslation: 'اللهم صل علی محمد و آل محمد',
        meaning: 'خدایا بر محمد و آل محمد درود فرست',
        category: 'ایام هفته',
        defaultCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['جمعه', 'ایام هفته', 'صلوات'],
        priority: 14,
      ),
    ];
    
    for (final dhikr in defaultDhikrs) {
      await _dhikrBox.put(dhikr.id, dhikr);
    }
    
    _dhikrs = _dhikrBox.values.toList();
  }
  
  // انتخاب ذکر برای شمارش
  Future<void> selectDhikr(DhikrModel dhikr) async {
    try {
      _currentDhikr = dhikr;
      _targetCount = dhikr.defaultCount;
      _currentCount = 0;
      _isCountingActive = false;
      _currentSession = null;
      _sessionStartTime = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در انتخاب ذکر: $e');
    }
  }
  
  // شروع جلسه شمارش
  Future<void> startSession() async {
    if (_currentDhikr == null) return;
    
    try {
      _sessionStartTime = DateTime.now();
      _isCountingActive = true;
      
      _currentSession = DhikrSessionModel(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        dhikrId: _currentDhikr!.id,
        targetCount: _targetCount,
        currentCount: 0,
        startTime: _sessionStartTime!,
        date: DateTime.now(),
        clickTimes: [],
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در شروع جلسه: $e');
    }
  }
  
  // شمارش (کلیک)
  Future<void> incrementCount() async {
    if (!_isCountingActive || _currentSession == null) return;
    
    try {
      _currentCount++;
      
      // اضافه کردن زمان کلیک
      final clickTime = DateTime.now();
      _currentSession = _currentSession!.copyWith(
        currentCount: _currentCount,
        clickTimes: [..._currentSession!.clickTimes, clickTime],
      );
      
      // بازخورد لمسی
      await _provideFeedback();
      
      // بررسی تکمیل
      if (_currentCount >= _targetCount) {
        await _completeSession();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در شمارش: $e');
    }
  }
  
  // کاهش شمارش
  Future<void> decrementCount() async {
    if (!_isCountingActive || _currentCount <= 0) return;
    
    try {
      _currentCount--;
      
      // حذف آخرین زمان کلیک
      final clickTimes = List<DateTime>.from(_currentSession!.clickTimes);
      if (clickTimes.isNotEmpty) {
        clickTimes.removeLast();
      }
      
      _currentSession = _currentSession!.copyWith(
        currentCount: _currentCount,
        clickTimes: clickTimes,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در کاهش شمارش: $e');
    }
  }
  
  // تکمیل جلسه
  Future<void> _completeSession() async {
    if (_currentSession == null) return;
    
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_sessionStartTime!);
      
      _currentSession = _currentSession!.copyWith(
        endTime: endTime,
        isCompleted: true,
        duration: duration,
      );
      
      // ذخیره جلسه
      await _sessionBox.put(_currentSession!.id, _currentSession!);
      
      // به‌روزرسانی آمار
      await _calculateStatistics();
      
      // بازخورد تکمیل
      await _provideCompletionFeedback();
      
    } catch (e) {
      debugPrint('خطا در تکمیل جلسه: $e');
    }
  }
  
  // توقف جلسه
  Future<void> stopSession() async {
    if (_currentSession == null) return;
    
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_sessionStartTime!);
      
      _currentSession = _currentSession!.copyWith(
        endTime: endTime,
        duration: duration,
      );
      
      // ذخیره جلسه اگر حداقل یک شمارش انجام شده
      if (_currentCount > 0) {
        await _sessionBox.put(_currentSession!.id, _currentSession!);
        await _calculateStatistics();
      }
      
      _isCountingActive = false;
      _currentSession = null;
      _sessionStartTime = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در توقف جلسه: $e');
    }
  }
  
  // بازنشانی شمارش
  Future<void> resetCount() async {
    try {
      _currentCount = 0;
      
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(
          currentCount: 0,
          clickTimes: [],
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در بازنشانی: $e');
    }
  }
  
  // تنظیم هدف
  Future<void> setTargetCount(int target) async {
    try {
      _targetCount = target.clamp(1, 1000);
      
      if (_currentSession != null) {
        _currentSession = _currentSession!.copyWith(targetCount: _targetCount);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در تنظیم هدف: $e');
    }
  }
  
  // بازخورد لمسی
  Future<void> _provideFeedback() async {
    try {
      // لرزش
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 50);
      }
      
      // بازخورد haptic
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('خطا در بازخورد: $e');
    }
  }
  
  // بازخورد تکمیل
  Future<void> _provideCompletionFeedback() async {
    try {
      // لرزش طولانی‌تر
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 200);
      }
      
      // بازخورد haptic قوی‌تر
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('خطا در بازخورد تکمیل: $e');
    }
  }
  
  // محاسبه آمار
  Future<void> _calculateStatistics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      
      final sessions = _sessionBox.values.toList();
      
      // آمار امروز
      _todayCount = sessions
          .where((s) => s.date.isAfter(today.subtract(const Duration(days: 1))))
          .fold(0, (sum, s) => sum + s.currentCount);
      
      // آمار هفته
      _weekCount = sessions
          .where((s) => s.date.isAfter(weekStart.subtract(const Duration(days: 1))))
          .fold(0, (sum, s) => sum + s.currentCount);
      
      // آمار ماه
      _monthCount = sessions
          .where((s) => s.date.isAfter(monthStart.subtract(const Duration(days: 1))))
          .fold(0, (sum, s) => sum + s.currentCount);
      
      // آمار کل
      _totalCount = sessions.fold(0, (sum, s) => sum + s.currentCount);
      
      // محاسبه streak
      _calculateStreak();
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در محاسبه آمار: $e');
    }
  }
  
  // محاسبه streak
  void _calculateStreak() {
    try {
      final sessions = _sessionBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      if (sessions.isEmpty) {
        _streakDays = 0;
        return;
      }
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      _streakDays = 0;
      DateTime checkDate = today;
      
      for (int i = 0; i < 365; i++) { // حداکثر یک سال
        final dayStart = checkDate;
        final dayEnd = checkDate.add(const Duration(days: 1));
        
        final dayHasSessions = sessions.any((s) =>
            s.date.isAfter(dayStart.subtract(const Duration(days: 1))) &&
            s.date.isBefore(dayEnd) &&
            s.currentCount > 0);
        
        if (dayHasSessions) {
          _streakDays++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    } catch (e) {
      debugPrint('خطا در محاسبه streak: $e');
      _streakDays = 0;
    }
  }
  
  // به‌روزرسانی دسته‌بندی‌ها
  void _updateCategories() {
    final categorySet = <String>{'همه'};
    for (final dhikr in _dhikrs) {
      categorySet.add(dhikr.category);
    }
    _categories = categorySet.toList()..sort();
  }
  
  // جستجو
  void searchDhikrs(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // فیلتر بر اساس دسته‌بندی
  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // دریافت اذکار فیلتر شده
  List<DhikrModel> get filteredDhikrs {
    var filtered = _dhikrs;
    
    // فیلتر بر اساس دسته‌بندی
    if (_selectedCategory != 'همه') {
      filtered = filtered.where((d) => d.category == _selectedCategory).toList();
    }
    
    // فیلتر بر اساس جستجو
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
          d.arabicText.contains(_searchQuery) ||
          d.persianTranslation.contains(_searchQuery) ||
          d.meaning.contains(_searchQuery) ||
          d.tags.any((tag) => tag.contains(_searchQuery))).toList();
    }
    
    return filtered;
  }
  
  // تغییر وضعیت علاقه‌مندی
  Future<void> toggleFavorite(DhikrModel dhikr) async {
    try {
      final updatedDhikr = dhikr.copyWith(
        isFavorite: !dhikr.isFavorite,
        updatedAt: DateTime.now(),
      );
      
      await _dhikrBox.put(dhikr.id, updatedDhikr);
      
      // به‌روزرسانی لیست‌ها
      final index = _dhikrs.indexWhere((d) => d.id == dhikr.id);
      if (index != -1) {
        _dhikrs[index] = updatedDhikr;
      }
      
      _favoriteDhikrs = _dhikrs.where((d) => d.isFavorite).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در تغییر علاقه‌مندی: $e');
    }
  }
}