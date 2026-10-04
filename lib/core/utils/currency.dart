import 'package:intl/intl.dart';

class CurrencyUtil {
  static final NumberFormat _phpFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '\u20B1',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _phpFormat.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}

class DateUtil {
  static final DateFormat _monthDayYear =
      DateFormat('MMM d, y');

  static String formatDate(DateTime date) {
    return _monthDayYear.format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
