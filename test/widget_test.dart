/// تست‌های واحد و ویجت برای اپلیکیشن ذکرهای من
/// 
/// این فایل شامل تست‌های اساسی برای بررسی عملکرد صحیح اپلیکیشن است.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zekrhaye_man/app/data/models/dhikr_model.dart';
import 'package:zekrhaye_man/app/data/models/dhikr_session_model.dart';

void main() {
  group('DhikrModel Tests', () {
    test('ایجاد یک ذکر جدید', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabicText: 'سُبْحَانَ اللَّهِ',
        persianTranslation: 'سبحان الله',
        meaning: 'خدا منزه و پاک است',
        category: 'تسبیحات',
        defaultCount: 33,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(dhikr.id, 'test_1');
      expect(dhikr.arabicText, 'سُبْحَانَ اللَّهِ');
      expect(dhikr.defaultCount, 33);
      expect(dhikr.isFavorite, false);
      expect(dhikr.isCustom, false);
    });

    test('تبدیل ذکر به Map و بازگشت', () {
      final dhikr = DhikrModel(
        id: 'test_2',
        arabicText: 'الْحَمْدُ لِلَّهِ',
        persianTranslation: 'الحمدلله',
        meaning: 'ستایش مخصوص خداست',
        category: 'تسبیحات',
        defaultCount: 33,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['حمد', 'شکر'],
      );

      final map = dhikr.toMap();
      final restoredDhikr = DhikrModel.fromMap(map);

      expect(restoredDhikr.id, dhikr.id);
      expect(restoredDhikr.arabicText, dhikr.arabicText);
      expect(restoredDhikr.persianTranslation, dhikr.persianTranslation);
      expect(restoredDhikr.tags.length, 2);
    });

    test('کپی ذکر با تغییرات', () {
      final dhikr = DhikrModel(
        id: 'test_3',
        arabicText: 'اللَّهُ أَكْبَرُ',
        persianTranslation: 'الله اکبر',
        meaning: 'خدا بزرگ‌تر است',
        category: 'تسبیحات',
        defaultCount: 34,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      final updatedDhikr = dhikr.copyWith(isFavorite: true);

      expect(updatedDhikr.isFavorite, true);
      expect(updatedDhikr.id, dhikr.id);
      expect(updatedDhikr.arabicText, dhikr.arabicText);
    });
  });

  group('DhikrSessionModel Tests', () {
    test('ایجاد یک جلسه جدید', () {
      final session = DhikrSessionModel(
        id: 'session_1',
        dhikrId: 'dhikr_1',
        targetCount: 33,
        currentCount: 0,
        startTime: DateTime.now(),
        date: DateTime.now(),
      );

      expect(session.targetCount, 33);
      expect(session.currentCount, 0);
      expect(session.isCompleted, false);
      expect(session.progressPercentage, 0.0);
      expect(session.remainingCount, 33);
    });

    test('محاسبه پیشرفت جلسه', () {
      final session = DhikrSessionModel(
        id: 'session_2',
        dhikrId: 'dhikr_1',
        targetCount: 100,
        currentCount: 50,
        startTime: DateTime.now(),
        date: DateTime.now(),
      );

      expect(session.progressPercentage, 0.5);
      expect(session.remainingCount, 50);
    });

    test('تکمیل جلسه', () {
      final session = DhikrSessionModel(
        id: 'session_3',
        dhikrId: 'dhikr_1',
        targetCount: 33,
        currentCount: 33,
        startTime: DateTime.now(),
        date: DateTime.now(),
        isCompleted: true,
      );

      expect(session.progressPercentage, 1.0);
      expect(session.remainingCount, 0);
      expect(session.isCompleted, true);
    });

    test('تبدیل جلسه به Map و بازگشت', () {
      final now = DateTime.now();
      final session = DhikrSessionModel(
        id: 'session_4',
        dhikrId: 'dhikr_1',
        targetCount: 100,
        currentCount: 25,
        startTime: now,
        date: now,
        duration: const Duration(minutes: 5),
      );

      final map = session.toMap();
      final restoredSession = DhikrSessionModel.fromMap(map);

      expect(restoredSession.id, session.id);
      expect(restoredSession.targetCount, session.targetCount);
      expect(restoredSession.currentCount, session.currentCount);
      expect(restoredSession.duration.inMinutes, 5);
    });
  });

  group('محاسبات آماری', () {
    test('محاسبه باقی‌مانده تا هدف', () {
      final session = DhikrSessionModel(
        id: 'stat_1',
        dhikrId: 'dhikr_1',
        targetCount: 100,
        currentCount: 75,
        startTime: DateTime.now(),
        date: DateTime.now(),
      );

      expect(session.remainingCount, 25);
    });

    test('محاسبه درصد پیشرفت', () {
      final session = DhikrSessionModel(
        id: 'stat_2',
        dhikrId: 'dhikr_1',
        targetCount: 200,
        currentCount: 50,
        startTime: DateTime.now(),
        date: DateTime.now(),
      );

      expect(session.progressPercentage, 0.25);
    });

    test('بررسی محدودیت پیشرفت (نباید بیشتر از 1 باشد)', () {
      final session = DhikrSessionModel(
        id: 'stat_3',
        dhikrId: 'dhikr_1',
        targetCount: 100,
        currentCount: 150,  // بیشتر از هدف
        startTime: DateTime.now(),
        date: DateTime.now(),
      );

      expect(session.progressPercentage, 1.0);
      expect(session.remainingCount, 0);
    });
  });

  // TODO: افزودن تست‌های ویجت
  // testWidgets('بررسی نمایش صحیح شمارنده', (WidgetTester tester) async {
  //   // تست‌های UI در آینده
  // });
}
