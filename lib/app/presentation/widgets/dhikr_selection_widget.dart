import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dhikr_provider.dart';
import '../providers/settings_provider.dart';
import '../pages/add_custom_dhikr_page.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dhikr_model.dart';

class DhikrSelectionWidget extends StatefulWidget {
  final bool showHeader;
  final TabController? tabController;
  final Function(DhikrModel)? onSetOverallGoal;

  const DhikrSelectionWidget({
    super.key,
    this.showHeader = false,
    this.tabController,
    this.onSetOverallGoal,
  });

  @override
  State<DhikrSelectionWidget> createState() => _DhikrSelectionWidgetState();
}

class _DhikrSelectionWidgetState extends State<DhikrSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DhikrProvider>(
      builder: (context, dhikrProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هدر (اختیاری)
            if (widget.showHeader) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'کتابخانه اذکار',
                      style: AppTheme.persianTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // دکمه افزودن ذکر سفارشی
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddCustomDhikr(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'ذکر جدید',
                      style: AppTheme.persianTextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // نوار جستجو و فیلتر
            _buildSearchAndFilter(dhikrProvider),
            
            const SizedBox(height: 16),
            
            // تب‌های دسته‌بندی
            _buildCategoryTabs(dhikrProvider),
            
            const SizedBox(height: 16),
            
            // لیست اذکار
            Expanded(
              child: _buildDhikrList(dhikrProvider),
            ),
          ],
        );
      },
    );
  }

  // نوار جستجو و فیلتر
  Widget _buildSearchAndFilter(DhikrProvider dhikrProvider) {
    return Row(
      children: [
        // فیلد جستجو
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'جستجو در اذکار...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        dhikrProvider.searchDhikrs('');
                      },
                    )
                  : null,
            ),
            onChanged: dhikrProvider.searchDhikrs,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // دکمه فیلتر علاقه‌مندی‌ها
        IconButton(
          onPressed: () => _showFavoritesDialog(dhikrProvider),
          icon: const Icon(Icons.favorite),
          tooltip: 'علاقه‌مندی‌ها',
        ),
      ],
    );
  }

  // تب‌های دسته‌بندی
  Widget _buildCategoryTabs(DhikrProvider dhikrProvider) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dhikrProvider.categories.length,
        itemBuilder: (context, index) {
          final category = dhikrProvider.categories[index];
          final isSelected = category == dhikrProvider.selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => dhikrProvider.filterByCategory(category),
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: AppTheme.persianTextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  // لیست اذکار
  Widget _buildDhikrList(DhikrProvider dhikrProvider) {
    final filteredDhikrs = dhikrProvider.filteredDhikrs;
    
    if (filteredDhikrs.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      itemCount: filteredDhikrs.length,
      itemBuilder: (context, index) {
        final dhikr = filteredDhikrs[index];
        return _buildDhikrCard(dhikr, dhikrProvider);
      },
    );
  }

  // کارت ذکر
  Widget _buildDhikrCard(DhikrModel dhikr, DhikrProvider dhikrProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isSelected = dhikrProvider.currentDhikr?.id == dhikr.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 2,
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : null,
          child: InkWell(
            onTap: () {
              dhikrProvider.selectDhikr(dhikr);
              widget.tabController?.animateTo(0); // بازگشت به تب خانه
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ردیف اول: متن عربی و دکمه علاقه‌مندی
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // متن عربی
                      Expanded(
                        child: Text(
                          dhikr.arabicText,
                          style: AppTheme.arabicTextStyle(
                            fontSize: settingsProvider.fontSize + 2,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primaryGreen : null,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      
                      // دکمه علاقه‌مندی
                      IconButton(
                        onPressed: () => dhikrProvider.toggleFavorite(dhikr),
                        icon: Icon(
                          dhikr.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: dhikr.isFavorite ? Colors.red : Colors.grey,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ترجمه فارسی
                  Text(
                    dhikr.persianTranslation,
                    style: AppTheme.persianTextStyle(
                      fontSize: settingsProvider.fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // معنی
                  Text(
                    dhikr.meaning,
                    style: AppTheme.persianTextStyle(
                      fontSize: settingsProvider.fontSize - 2,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // ردیف پایین: اطلاعات اضافی
                  Row(
                    children: [
                      // دسته‌بندی
                      _buildInfoChip(
                        text: dhikr.category,
                        color: AppTheme.primaryGreen,
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // تعداد پیش‌فرض
                      _buildInfoChip(
                        text: '${dhikr.defaultCount} بار',
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(width: 8),

                      // هدف کلی
                      if (dhikr.overallGoal != null && dhikr.overallGoal! > 0)
                        _buildInfoChip(
                          text: 'هدف: ${dhikr.overallGoal}',
                          color: Colors.purple,
                          icon: Icons.track_changes,
                        ),

                      const Spacer(),
                      
                      // دکمه تنظیم هدف کلی
                      IconButton(
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: 'تنظیم هدف کلی',
                        onPressed: () => widget.onSetOverallGoal?.call(dhikr),
                        color: Colors.grey[600],
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ویجت برای نمایش چیپ‌های اطلاعاتی
  Widget _buildInfoChip({required String text, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTheme.persianTextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // حالت خالی
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'هیچ ذکری یافت نشد',
            style: AppTheme.persianTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لطفاً کلمات جستجو یا فیلتر را تغییر دهید',
            style: AppTheme.persianTextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // نمایش صفحه افزودن ذکر سفارشی
  void _navigateToAddCustomDhikr(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomDhikrPage(),
      ),
    );
    
    // اگر ذکر جدید اضافه شد، setState را فراخوانی کن
    if (result == true && mounted) {
      setState(() {});
    }
  }

  // نمایش دیالوگ علاقه‌مندی‌ها
  void _showFavoritesDialog(DhikrProvider dhikrProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اذکار مورد علاقه'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: dhikrProvider.favoriteDhikrs.isEmpty
              ? const Center(
                  child: Text('هنوز ذکری به علاقه‌مندی‌ها اضافه نشده است'),
                )
              : ListView.builder(
                  itemCount: dhikrProvider.favoriteDhikrs.length,
                  itemBuilder: (context, index) {
                    final dhikr = dhikrProvider.favoriteDhikrs[index];
                    return ListTile(
                      title: Text(
                        dhikr.persianTranslation,
                        style: AppTheme.persianTextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        dhikr.arabicText,
                        style: AppTheme.arabicTextStyle(fontSize: 12),
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => dhikrProvider.toggleFavorite(dhikr),
                      ),
                      onTap: () {
                        dhikrProvider.selectDhikr(dhikr);
                        Navigator.pop(context);
                        widget.tabController?.animateTo(0);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }
}