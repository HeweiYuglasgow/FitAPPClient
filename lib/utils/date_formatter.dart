import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Date formatting utility class
class DateFormatter {
  /// Default date format
  static const String defaultDateFormat = 'yyyy-MM-dd';
  
  /// Default time format
  static const String defaultTimeFormat = 'HH:mm:ss';
  
  /// Default datetime format
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  /// English date format
  static const String chineseDateFormat = 'yyyy-MM-dd';
  
  /// English time format
  static const String chineseTimeFormat = 'HH:mm';
  
  /// English datetime format
  static const String chineseDateTimeFormat = 'yyyy-MM-dd HH:mm';
  
  /// Format date
  static String formatDate(DateTime date, {String format = defaultDateFormat}) {
    return DateFormat(format).format(date);
  }
  
  /// Format time
  static String formatTime(DateTime date, {String format = defaultTimeFormat}) {
    return DateFormat(format).format(date);
  }
  
  /// Format datetime
  static String formatDateTime(DateTime date, {String format = defaultDateTimeFormat}) {
    return DateFormat(format).format(date);
  }
  
  /// Format as English date
  static String formatChineseDate(DateTime date) {
    return formatDate(date, format: chineseDateFormat);
  }
  
  /// Format as English time
  static String formatChineseTime(DateTime date) {
    return formatTime(date, format: chineseTimeFormat);
  }
  
  /// Format as English datetime
  static String formatChineseDateTime(DateTime date) {
    return formatDateTime(date, format: chineseDateTimeFormat);
  }
  
  /// Get relative time description
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
  
  /// Get today's date range
  static DateTimeRange getTodayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return DateTimeRange(start: today, end: tomorrow);
  }
  
  /// Get this week's date range
  static DateTimeRange getThisWeekRange() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return DateTimeRange(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }
  
  /// Get this month's date range
  static DateTimeRange getThisMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return DateTimeRange(start: startOfMonth, end: endOfMonth);
  }
  
  /// Get this year's date range
  static DateTimeRange getThisYearRange() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1);
    
    return DateTimeRange(start: startOfYear, end: endOfYear);
  }
  
  /// Check if it's the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Check if it's today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// Check if it's yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  /// Check if it's this week
  static bool isThisWeek(DateTime date) {
    final weekRange = getThisWeekRange();
    return date.isAfter(weekRange.start) && date.isBefore(weekRange.end);
  }
  
  /// Check if it's this month
  static bool isThisMonth(DateTime date) {
    final monthRange = getThisMonthRange();
    return date.isAfter(monthRange.start) && date.isBefore(monthRange.end);
  }
  
  /// Get friendly date display
  static String getFriendlyDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isThisWeek(date)) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else if (isThisMonth(date)) {
      return '${date.day}th';
    } else {
      return formatDate(date);
    }
  }
  
  /// Format duration (seconds)
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0 ? '${minutes}m ${remainingSeconds}s' : '${minutes} min';
    } else {
      final hours = seconds ~/ 3600;
      final remainingMinutes = (seconds % 3600) ~/ 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}min' : '${hours}h';
    }
  }
  
  /// Format duration (minutes)
  static String formatDurationMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}min' : '${hours}h';
    }
  }
}