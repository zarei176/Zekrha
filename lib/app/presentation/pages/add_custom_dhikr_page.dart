import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/dhikr_model.dart';
import '../providers/dhikr_provider.dart';

/// صفحه افزودن ذکر سفارشی
/// 
/// این صفحه به کاربر اجازه می‌دهد اذکار شخصی خود را ایجاد و ذخیره کند.
class AddCustomDhikrPage extends StatefulWidget {
  final DhikrModel? editingDhikr; // برای ویرایش ذکر موجود

  const AddCustomDhikrPage({
    super.key,
    this.editingDhikr,
  });

  @override
  State<AddCustomDhikrPage> createState() => _AddCustomDhikrPageState();
}

class _AddCustomDhikrPageState extends State<AddCustomDhikrPage> {
  final _formKey = GlobalKey<FormState>();
  
  // کنترلرها
  late TextEditingController _arabicController;
  late TextEditingController _persianController;
  late TextEditingController _meaningController;
  late TextEditingController _categoryController;
  late TextEditingController _defaultCountController;
  late TextEditingController _tagsController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    _isEditing = widget.editingDhikr != null;
    
    // مقداردهی اولیه کنترلرها
    _arabicController = TextEditingController(
      text: widget.editingDhikr?.arabicText ?? '',
    );
    _persianController = TextEditingController(
      text: widget.editingDhikr?.persianTranslation ?? '',
    );
    _meaningController = TextEditingController(
      text: widget.editingDhikr?.meaning ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.editingDhikr?.category ?? 'سفارشی',
    );
    _defaultCountController = TextEditingController(
      text: widget.editingDhikr?.defaultCount.toString() ?? '33',
    );
    _tagsController = TextEditingController(
      text: widget.editingDhikr?.tags.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _persianController.dispose();
    _meaningController.dispose();
    _categoryController.dispose();
    _defaultCountController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'ویرایش ذکر' : 'افزودن ذکر سفارشی',
          style: AppTheme.persianTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // توضیحات
            Card(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'اذکار شخصی خود را اضافه کرده و مدیریت کنید',
                        style: AppTheme.persianTextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // متن عربی
            TextFormField(
              controller: _arabicController,
              decoration: InputDecoration(
                labelText: 'متن عربی *',
                hintText: 'مثال: سُبْحَانَ اللَّهِ',
                prefixIcon: const Icon(Icons.text_fields),
              ),
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicTextStyle(fontSize: 16),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً متن عربی را وارد کنید';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // ترجمه فارسی
            TextFormField(
              controller: _persianController,
              decoration: const InputDecoration(
                labelText: 'ترجمه فارسی *',
                hintText: 'مثال: سبحان الله',
                prefixIcon: Icon(Icons.translate),
              ),
              style: AppTheme.persianTextStyle(fontSize: 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً ترجمه فارسی را وارد کنید';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // معنی
            TextFormField(
              controller: _meaningController,
              decoration: const InputDecoration(
                labelText: 'معنی *',
                hintText: 'مثال: خدا منزه و پاک است',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              style: AppTheme.persianTextStyle(fontSize: 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً معنی را وارد کنید';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // دسته‌بندی
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'دسته‌بندی',
                hintText: 'مثال: تسبیحات',
                prefixIcon: Icon(Icons.category),
              ),
              style: AppTheme.persianTextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 16),
            
            // تعداد پیش‌فرض
            TextFormField(
              controller: _defaultCountController,
              decoration: const InputDecoration(
                labelText: 'تعداد پیش‌فرض',
                hintText: 'مثال: 33',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              style: AppTheme.persianTextStyle(fontSize: 14),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً تعداد را وارد کنید';
                }
                final count = int.tryParse(value);
                if (count == null || count <= 0) {
                  return 'تعداد باید یک عدد مثبت باشد';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // برچسب‌ها
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'برچسب‌ها (با کاما جدا کنید)',
                hintText: 'مثال: ذکر, تسبیح, عبادت',
                prefixIcon: Icon(Icons.label),
              ),
              style: AppTheme.persianTextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 32),
            
            // دکمه‌های عملیات
            Row(
              children: [
                // دکمه لغو
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('لغو'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // دکمه ذخیره
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveDhikr,
                    icon: const Icon(Icons.save),
                    label: Text(_isEditing ? 'ذخیره تغییرات' : 'افزودن ذکر'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // دکمه حذف (فقط در حالت ویرایش)
            if (_isEditing)
              OutlinedButton.icon(
                onPressed: _deleteDhikr,
                icon: const Icon(Icons.delete),
                label: const Text('حذف ذکر'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ذخیره ذکر
  void _saveDhikr() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
      
      // استخراج برچسب‌ها
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      // ایجاد یا ویرایش ذکر
      final dhikr = DhikrModel(
        id: _isEditing 
            ? widget.editingDhikr!.id 
            : 'custom_${DateTime.now().millisecondsSinceEpoch}',
        arabicText: _arabicController.text.trim(),
        persianTranslation: _persianController.text.trim(),
        meaning: _meaningController.text.trim(),
        category: _categoryController.text.trim().isEmpty 
            ? 'سفارشی' 
            : _categoryController.text.trim(),
        defaultCount: int.parse(_defaultCountController.text),
        createdAt: _isEditing 
            ? widget.editingDhikr!.createdAt 
            : DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        isCustom: true,
        isFavorite: _isEditing ? widget.editingDhikr!.isFavorite : false,
      );
      
      // ذخیره در provider
      await dhikrProvider.saveCustomDhikr(dhikr);
      
      // نمایش پیام موفقیت
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'ذکر با موفقیت ویرایش شد' 
                  : 'ذکر جدید با موفقیت اضافه شد',
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      // نمایش پیام خطا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // حذف ذکر
  void _deleteDhikr() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف ذکر'),
        content: const Text('آیا مطمئن هستید که می‌خواهید این ذکر را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final dhikrProvider = Provider.of<DhikrProvider>(
                  context, 
                  listen: false,
                );
                
                await dhikrProvider.deleteCustomDhikr(widget.editingDhikr!);
                
                if (mounted) {
                  Navigator.pop(context); // بستن دیالوگ
                  Navigator.pop(context, true); // بستن صفحه
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ذکر با موفقیت حذف شد'),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطا در حذف: $e'),
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
