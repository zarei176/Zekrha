import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/dhikr_provider.dart';
import '../../core/theme/app_theme.dart';

class ProgressCardWidget extends StatelessWidget {
  const ProgressCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        if (dhikrProvider.currentDhikr == null) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // عنوان کارت
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'پیشرفت جلسه',
                      style: AppTheme.persianTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (dhikrProvider.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'تکمیل شده',
                              style: AppTheme.persianTextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // نمایش پیشرفت دایره‌ای
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  animation: true,
                  animationDuration: 1000,
                  percent: dhikrProvider.progressPercentage,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dhikrProvider.currentCount}',
                        style: AppTheme.persianTextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Text(
                        'از ${dhikrProvider.targetCount}',
                        style: AppTheme.persianTextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: dhikrProvider.isCompleted
                      ? AppTheme.successColor
                      : AppTheme.primaryGreen,
                  backgroundColor: Colors.grey[300]!,
                ),
                
                const SizedBox(height: 20),
                
                // اطلاعات تکمیلی
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // باقی‌مانده
                    _buildInfoItem(
                      icon: Icons.schedule,
                      label: 'باقی‌مانده',
                      value: '${dhikrProvider.remainingCount}',
                      color: Colors.orange,
                    ),
                    
                    // درصد پیشرفت
                    _buildInfoItem(
                      icon: Icons.percent,
                      label: 'پیشرفت',
                      value: '${(dhikrProvider.progressPercentage * 100).toInt()}%',
                      color: AppTheme.primaryGreen,
                    ),
                    
                    // وضعیت جلسه
                    _buildInfoItem(
                      icon: dhikrProvider.isCountingActive
                          ? Icons.play_circle_filled
                          : Icons.pause_circle_filled,
                      label: 'وضعیت',
                      value: dhikrProvider.isCountingActive ? 'فعال' : 'متوقف',
                      color: dhikrProvider.isCountingActive
                          ? AppTheme.successColor
                          : Colors.grey,
                    ),
                  ],
                ),
                
                // زمان جلسه (اگر شروع شده باشد)
                if (dhikrProvider.sessionStartTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'شروع جلسه: ${_formatTime(dhikrProvider.sessionStartTime!)}',
                          style: AppTheme.persianTextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (dhikrProvider.isCountingActive)
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final duration = DateTime.now().difference(
                                dhikrProvider.sessionStartTime!,
                              );
                              return Text(
                                _formatDuration(duration),
                                style: AppTheme.persianTextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                
                // نوار پیشرفت خطی (برای نمایش بهتر)
                if (dhikrProvider.currentCount > 0) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'پیشرفت تفصیلی',
                            style: AppTheme.persianTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${dhikrProvider.currentCount}/${dhikrProvider.targetCount}',
                            style: AppTheme.persianTextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: dhikrProvider.progressPercentage,
                        backgroundColor: Colors.grey[300],
                        progressColor: dhikrProvider.isCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryGreen,
                        barRadius: const Radius.circular(4),
                        animation: true,
                        animationDuration: 500,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ساخت آیتم اطلاعات
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.persianTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.persianTextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // فرمت کردن زمان
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // فرمت کردن مدت زمان
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}