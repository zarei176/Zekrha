import 'package:hive/hive.dart';

/// آداپتر Hive برای ذخیره و بازیابی نوع داده Duration
/// 
/// Hive به طور پیش‌فرض از Duration پشتیبانی نمی‌کند، بنابراین این آداپتر
/// آن را به یک عدد صحیح (میکروثانیه) تبدیل می‌کند تا قابل ذخیره‌سازی باشد.
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 100; // یک شناسه منحصر به فرد برای این نوع

  @override
  Duration read(BinaryReader reader) {
    // خواندن عدد صحیح (میکروثانیه) از پایگاه داده
    final microseconds = reader.readInt();
    // تبدیل عدد به Duration
    return Duration(microseconds: microseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    // نوشتن Duration به صورت میکروثانیه در پایگاه داده
    writer.writeInt(obj.inMicroseconds);
  }
}
