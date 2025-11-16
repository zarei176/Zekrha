import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dhikr_provider.dart';
import '../../core/theme/app_theme.dart';

class DhikrCounterWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const DhikrCounterWidget({
    super.key,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return Column(
          children: [
            // شمارنده اصلی
            _buildMainCounter(context, dhikrProvider),
            
            const SizedBox(height: 16),
            
            // دکمه‌های کنترل سریع
            _buildQuickControls(dhikrProvider),
          ],
        );
      },
    );
  }

  // شمارنده اصلی
  Widget _buildMainCounter(BuildContext context, DhikrProvider dhikrProvider) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: dhikrProvider.isCountingActive ? pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: dhikrProvider.isCountingActive ? dhikrProvider.incrementCount : null,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: dhikrProvider.isCountingActive
                      ? [AppTheme.primaryGreen, AppTheme.secondaryTeal]
                      : [Colors.grey[300]!, Colors.grey[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: dhikrProvider.isCountingActive
                        ? AppTheme.primaryGreen.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // شمارش فعلی
                  Text(
                    dhikrProvider.currentCount.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  // خط تقسیم
                  Container(
                    width: 40,
                    height: 2,
                    color: Colors.white.withOpacity(0.7),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  
                  // هدف
                  Text(
                    dhikrProvider.targetCount.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  // متن راهنما
                  if (!dhikrProvider.isCountingActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'شروع کنید',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // دکمه‌های کنترل سریع
  Widget _buildQuickControls(DhikrProvider dhikrProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // دکمه کاهش
        _buildQuickButton(
          icon: Icons.remove,
          onPressed: dhikrProvider.isCountingActive && dhikrProvider.currentCount > 0
              ? dhikrProvider.decrementCount
              : null,
          color: Colors.red,
        ),
        
        // نمایش پیشرفت
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // نوار پیشرفت
                LinearProgressIndicator(
                  value: dhikrProvider.progressPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  minHeight: 8,
                ),
                
                const SizedBox(height: 8),
                
                // درصد پیشرفت
                Text(
                  '${(dhikrProvider.progressPercentage * 100).toInt()}%',
                  style: AppTheme.persianTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // دکمه افزایش
        _buildQuickButton(
          icon: Icons.add,
          onPressed: dhikrProvider.isCountingActive
              ? dhikrProvider.incrementCount
              : null,
          color: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  // دکمه سریع
  Widget _buildQuickButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          elevation: 0,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}