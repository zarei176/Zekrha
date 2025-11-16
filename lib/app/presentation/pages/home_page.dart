import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;

import '../../data/models/dhikr_model.dart';
import '../providers/dhikr_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/dhikr_counter_widget.dart';
import '../widgets/dhikr_selection_widget.dart';
import '../widgets/stats_overview_widget.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    
    // انیمیشن پالس برای دکمه شمارش
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // هدر اپلیکیشن
            _buildHeader(),
            
            // محتوای اصلی با تب‌ها
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCounterTab(),
                  _buildDhikrLibraryTab(),
                  _buildStatsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // نوار پایین
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ساخت هدر
  Widget _buildHeader() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen,
                AppTheme.secondaryTeal,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              // آیکون اپلیکیشن
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // عنوان
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ذکرهای من',
                      style: AppTheme.persianTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'اپلیکیشن ذکرشمار هوشمند',
                      style: AppTheme.persianTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // دکمه تغییر تم
              IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(
                  themeProvider.currentThemeIcon,
                  color: Colors.white,
                ),
                tooltip: 'تغییر تم',
              ),
            ],
          ),
        );
      },
    );
  }

  // تب شمارنده
  Widget _buildCounterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // نمایش ذکر فعلی
          _buildCurrentDhikrDisplay(),
          
          const SizedBox(height: 24),
          
          // شمارنده اصلی
          DhikrCounterWidget(
            pulseAnimation: _pulseAnimation,
          ),
          
          const SizedBox(height: 20),
          
          // دکمه‌های کنترل
          _buildControlButtons(),
          
          const SizedBox(height: 20),
          
          // آمار سریع
          StatsOverviewWidget(),
        ],
      ),
    );
  }

  // ویجت نمایش ذکر فعلی
  Widget _buildCurrentDhikrDisplay() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        final currentDhikr = dhikrProvider.currentDhikr;
        
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () => _tabController.animateTo(1), // رفتن به تب کتابخانه
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: currentDhikr == null
                  ? _buildSelectDhikrPrompt()
                  : _buildDhikrDetails(currentDhikr),
            ),
          ),
        );
      },
    );
  }

  // پیام برای انتخاب ذکر
  Widget _buildSelectDhikrPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.touch_app, color: AppTheme.primaryGreen),
        const SizedBox(width: 12),
        Text(
          'برای شروع، یک ذکر انتخاب کنید',
          style: AppTheme.persianTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // جزئیات ذکر انتخاب شده
  Widget _buildDhikrDetails(DhikrModel dhikr) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dhikr.arabicText,
              style: AppTheme.arabicTextStyle(
                fontSize: settingsProvider.fontSize + 4,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              
            ),
            const SizedBox(height: 8),
            Text(
              dhikr.persianTranslation,
              style: AppTheme.persianTextStyle(
                fontSize: settingsProvider.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dhikr.meaning,
              style: AppTheme.persianTextStyle(
                fontSize: settingsProvider.fontSize - 2,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تغییر ذکر',
                  style: AppTheme.persianTextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
              ],
            ),
          ],
        );
      },
    );
  }

  // دکمه‌های کنترل
  Widget _buildControlButtons() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        final bool canCount = dhikrProvider.isCountingActive;
        
        return Column(
          children: [
            // ردیف اول
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // دکمه بازنشانی
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'بازنشانی',
                  onPressed: canCount ? () => dhikrProvider.resetCount() : null,
                  color: Colors.orange,
                ),
                
                // دکمه شروع/توقف
                _buildControlButton(
                  icon: canCount ? Icons.pause : Icons.play_arrow,
                  label: canCount ? 'توقف' : 'شروع',
                  onPressed: dhikrProvider.currentDhikr != null
                      ? () {
                          if (canCount) {
                            dhikrProvider.stopSession();
                          } else {
                            dhikrProvider.startSession();
                          }
                        }
                      : null,
                  color: canCount ? Colors.red : AppTheme.primaryGreen,
                ),
                
                // دکمه +10
                _buildControlButton(
                  icon: Icons.add,
                  label: '+10',
                  onPressed: canCount ? () => dhikrProvider.incrementBy(10) : null,
                  color: Colors.purple,
                ),
                
                // دکمه ذخیره
                _buildControlButton(
                  icon: Icons.save,
                  label: 'ذخیره',
                  onPressed: canCount && dhikrProvider.currentCount > 0
                      ? () => _saveSession(dhikrProvider)
                      : null,
                  color: Colors.teal,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // دکمه تنظیم هدف (زیر)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: dhikrProvider.currentDhikr != null ? () => _showTargetDialog() : null,
                icon: const Icon(Icons.flag, size: 18),
                label: Text(
                  'تنظیم هدف: ${dhikrProvider.targetCount}',
                  style: AppTheme.persianTextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ساخت دکمه کنترل
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: 4,
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.persianTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // تب کتابخانه اذکار
  Widget _buildDhikrLibraryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DhikrSelectionWidget(
        showHeader: true,
        tabController: _tabController,
        onSetOverallGoal: (dhikr) => _showOverallGoalDialog(dhikr),
      ),
    );
  }

  // تب آمار
  Widget _buildStatsTab() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان
              Text(
                'آمار و گزارش‌ها',
                style: AppTheme.persianTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // آمار کلی
              _buildStatsCards(),
              
              const SizedBox(height: 20),
              
              // نمودار پیشرفت
              _buildProgressChart(),
              
              const SizedBox(height: 20),
              
              // جلسات اخیر
              _buildRecentSessions(),
            ],
          ),
        );
      },
    );
  }

  // کارت‌های آمار
  Widget _buildStatsCards() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: 'امروز',
              value: dhikrProvider.todayCount.toString(),
              icon: Icons.today,
              color: AppTheme.primaryGreen,
            ),
            _buildStatCard(
              title: 'این هفته',
              value: dhikrProvider.weekCount.toString(),
              icon: Icons.date_range,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'این ماه',
              value: dhikrProvider.monthCount.toString(),
              icon: Icons.calendar_month,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'مداومت',
              value: '${dhikrProvider.streakDays} روز',
              icon: Icons.local_fire_department,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  // کارت آمار
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.persianTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.persianTextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // نمودار پیشرفت
  Widget _buildProgressChart() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'پیشرفت هفتگی',
                      style: AppTheme.persianTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'هفته اخیر',
                        style: AppTheme.persianTextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildWeeklyChart(dhikrProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // نمودار میله‌ای هفتگی
  Widget _buildWeeklyChart(DhikrProvider dhikrProvider) {
    // داده‌های 7 روز گذشته
    final weekData = _getWeeklyData(dhikrProvider);
    
    if (weekData.isEmpty || weekData.every((count) => count == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'هنوز داده‌ای برای نمایش وجود ندارد',
              style: AppTheme.persianTextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (weekData.reduce((a, b) => a > b ? a : b) * 1.2),
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppTheme.primaryGreen,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} ذکر\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: _getWeekDayName(groupIndex),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getWeekDayName(value.toInt()),
                    style: AppTheme.persianTextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: AppTheme.persianTextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            left: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        barGroups: weekData.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.secondaryTeal,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // دریافت داده‌های هفتگی
  List<double> _getWeeklyData(DhikrProvider dhikrProvider) {
    final now = DateTime.now();
    final weekData = List<double>.filled(7, 0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final daySessions = dhikrProvider.recentSessions.where((session) =>
        session.date.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
        session.date.isBefore(dayEnd));
      
      weekData[i] = daySessions.fold(0.0, (sum, session) => sum + session.currentCount);
    }
    
    return weekData;
  }

  // دریافت نام روز هفته
  String _getWeekDayName(int index) {
    final weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    return weekDays[index % 7];
  }

  // جلسات اخیر
  Widget _buildRecentSessions() {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        final recentSessions = dhikrProvider.recentSessions.take(5).toList();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جلسات اخیر',
                  style: AppTheme.persianTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (recentSessions.isEmpty)
                  const Center(
                    child: Text(
                      'هنوز جلسه‌ای ثبت نشده است',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...recentSessions.map((session) => _buildSessionItem(session)),
              ],
            ),
          ),
        );
      },
    );
  }

  // آیتم جلسه
  Widget _buildSessionItem(session) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            (session.isCompleted as bool) ? Icons.check_circle : Icons.radio_button_unchecked,
            color: (session.isCompleted as bool) ? AppTheme.primaryGreen : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.currentCount}/${session.targetCount}',
                  style: AppTheme.persianTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(session.date as DateTime),
                  style: AppTheme.persianTextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (session.isCompleted as bool)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'تکمیل شده',
                style: AppTheme.persianTextStyle(
                  fontSize: 10,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // تب تنظیمات
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تنظیمات',
            style: AppTheme.persianTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // تنظیمات عمومی
          _buildSettingsSection(),
        ],
      ),
    );
  }

  // بخش تنظیمات
  Widget _buildSettingsSection() {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, child) {
        return Column(
          children: [
            // تنظیمات صدا و لرزش
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('صدا'),
                    subtitle: const Text('فعال‌سازی صدای شمارش'),
                    trailing: Switch(
                      value: settingsProvider.soundEnabled,
                      onChanged: settingsProvider.setSoundEnabled,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.vibration),
                    title: const Text('لرزش'),
                    subtitle: const Text('فعال‌سازی لرزش هنگام شمارش'),
                    trailing: Switch(
                      value: settingsProvider.vibrationEnabled,
                      onChanged: settingsProvider.setVibrationEnabled,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // تنظیمات نمایش
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: const Text('اندازه فونت'),
                    subtitle: Text('${settingsProvider.fontSize.toInt()}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Slider(
                        value: settingsProvider.fontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        onChanged: settingsProvider.setFontSize,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(themeProvider.currentThemeIcon),
                    title: const Text('تم'),
                    subtitle: Text(themeProvider.currentThemeName),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _showThemeDialog(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // تنظیمات اعلان‌ها
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('اعلان‌ها'),
                subtitle: const Text('یادآوری‌های روزانه'),
                trailing: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: settingsProvider.setNotificationsEnabled,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // نوار پایین
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryGreen,
        tabs: const [
          Tab(
            icon: Icon(Icons.home),
            text: 'خانه',
          ),
          Tab(
            icon: Icon(Icons.library_books),
            text: 'کتابخانه',
          ),
          Tab(
            icon: Icon(Icons.bar_chart),
            text: 'آمار',
          ),
          Tab(
            icon: Icon(Icons.settings),
            text: 'تنظیمات',
          ),
        ],
      ),
    );
  }

  // ذخیره جلسه
  void _saveSession(DhikrProvider dhikrProvider) async {
    try {
      // جلسه قبلاً در incrementCount ذخیره شده
      // این دکمه فقط یک تأیید بصری برای کاربر است
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'جلسه با موفقیت ذخیره شد: ${dhikrProvider.currentCount} ذکر',
                  style: AppTheme.persianTextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ذخیره: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // نمایش دیالوگ تنظیم هدف
  void _showTargetDialog() {
    final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
    final controller = TextEditingController(
      text: dhikrProvider.targetCount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیم هدف روزانه'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'تعداد هدف',
            hintText: 'مثال: 33',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(controller.text) ?? 33;
              dhikrProvider.setTargetCount(target);
              Navigator.pop(context);
            },
            child: const Text('تایید'),
          ),
        ],
      ),
    );
  }

  // نمایش دیالوگ تنظیم هدف کلی
  void _showOverallGoalDialog(DhikrModel dhikr) {
    final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
    final controller = TextEditingController(
      text: dhikr.overallGoal?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیم هدف کلی'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'تعداد هدف کلی',
            hintText: 'اختیاری',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              dhikrProvider.setOverallGoal(dhikr, goal);
              Navigator.pop(context);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  // نمایش دیالوگ انتخاب تم
  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتخاب تم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeProvider.availableThemes.map((theme) {
            return RadioListTile<ThemeMode>(
              title: Text(theme['name'] as String),
              subtitle: Text(theme['description'] as String),
              value: theme['value'] as ThemeMode,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  switch (value) {
                    case ThemeMode.light:
                      themeProvider.setLightMode();
                      break;
                    case ThemeMode.dark:
                      themeProvider.setDarkMode();
                      break;
                    case ThemeMode.system:
                      themeProvider.setSystemMode();
                      break;
                  }
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // فرمت کردن تاریخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'امروز';
    } else if (dateOnly == yesterday) {
      return 'دیروز';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}