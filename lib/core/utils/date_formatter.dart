import 'package:intl/intl.dart';

/// Utility class for formatting publication dates and relative time
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');

  /// Formats ISO 8601 string to 'MMM dd, yyyy' (e.g., 'Feb 27, 2023')
  static String formatStandard(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown date';
    try {
      return _displayFormat.format(dateTime.toLocal());
    } catch (_) {
      return 'Unknown date';
    }
  }

  /// Parses an ISO 8601 string safely
  static DateTime? parseIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Returns relative time string like 'Just now', '15m ago', '3 hours ago', 'Yesterday'
  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatStandard(dateTime);
    }
  }
}
