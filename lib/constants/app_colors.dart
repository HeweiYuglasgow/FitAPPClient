import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  /// 主色调
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3F34CC);
  
  /// 次要颜色
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF5DDEF4);
  static const Color secondaryDark = Color(0xFF00A896);
  
  /// 情绪颜色
  static const Color moodGood = Color(0xFF4CAF50); // 绿色
  static const Color moodNormal = Color(0xFFFF9800); // 橙色
  static const Color moodBad = Color(0xFFFF5722); // 深橙色
  
  /// 状态颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  /// 中性颜色
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  /// 背景颜色
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  /// 文本颜色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// 分隔线颜色
  static const Color divider = Color(0xFFE0E0E0);
  
  /// 阴影颜色
  static const Color shadow = Color(0x1A000000);
  
  /// 透明颜色
  static const Color transparent = Colors.transparent;
  
  /// 获取情绪颜色
  static Color getMoodColor(String mood) {
    switch (mood) {
      case 'good':
        return moodGood;
      case 'normal':
        return moodNormal;
      case 'bad':
        return moodBad;
      default:
        return grey500;
    }
  }
  
  /// 获取情绪颜色的浅色版本
  static Color getMoodColorLight(String mood) {
    return getMoodColor(mood).withOpacity(0.2);
  }
  
  /// 获取完成率颜色
  static Color getCompletionRateColor(double rate) {
    if (rate >= 90) {
      return success;
    } else if (rate >= 70) {
      return moodGood;
    } else if (rate >= 50) {
      return warning;
    } else {
      return error;
    }
  }
}