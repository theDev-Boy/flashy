class DateUtils {
  DateUtils._();

  static String formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today ${_formatTime(date)}';
    }
    if (dateDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_formatTime(date)}';
    }
    return '${date.month}/${date.day}/${date.year} ${_formatTime(date)}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDateShort(date);
  }

  static String formatDateShort(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  static String formatTimestamp(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return formatRelative(date);
  }
}
