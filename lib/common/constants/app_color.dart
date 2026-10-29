import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 1. Màu thương hiệu chính (Primary & Accent)
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);

  // 2. Màu nền & Bề mặt (Background & Surface)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // 3. Đường viền & Phân cách (Border & Divider)
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF1E40AF);
  static const Color divider = Color(0xFFCBD5E1);

  // 4. Màu văn bản (Typography)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // 5. Màu trạng thái (Feedback)
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
}
