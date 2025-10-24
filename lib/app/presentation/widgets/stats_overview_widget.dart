import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dhikr_provider.dart';
import '../../core/theme/app_theme.dart';

class StatsOverviewWidget extends StatelessWidget {
  const StatsOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'آمار سریع',
                      style: AppTheme.persianTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // آمار در یک ردیف
                Row(
                  children: [
                    // آمار امروز
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.today,
                        label: 'امروز',
                        value: dhikrProvider.todayCount.toString(),
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    
                    // آمار هفته
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.date_range,
                        label: 'این هفته',
                        value: dhikrProvider.weekCount.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    
                    // مداومت
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.local_fire_department,
                        label: 'مداومت',
                        value: '${dhikrProvider.streakDays}',
                        color: Colors.orange,
                        suffix: 'روز',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // نوار پیشرفت هدف روزانه
                _buildDailyGoalProgress(dhikrProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  // آیتم آمار
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? suffix,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTheme.persianTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: AppTheme.persianTextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.persianTextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // پیشرفت هدف روزانه
  Widget _buildDailyGoalProgress(DhikrProvider dhikrProvider) {
    // فرض می‌کنیم هدف روزانه 100 است (می‌توان از SettingsProvider دریافت کرد)
    const dailyGoal = 100;
    final progress = (dhikrProvider.todayCount / dailyGoal).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'هدف روزانه',
              style: AppTheme.persianTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${dhikrProvider.todayCount}/$dailyGoal',
              style: AppTheme.persianTextStyle(
                fontSize: 14,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // نوار پیشرفت
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress >= 1.0
                      ? [AppTheme.successColor, AppTheme.successColor]
                      : [AppTheme.primaryGreen, AppTheme.secondaryTeal],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // متن پیشرفت
        Text(
          progress >= 1.0
              ? '🎉 هدف روزانه تکمیل شد!'
              : 'تا تکمیل هدف ${dailyGoal - dhikrProvider.todayCount} ذکر باقی مانده',
          style: AppTheme.persianTextStyle(
            fontSize: 12,
            color: progress >= 1.0 ? AppTheme.successColor : Colors.grey[600],
            fontWeight: progress >= 1.0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}