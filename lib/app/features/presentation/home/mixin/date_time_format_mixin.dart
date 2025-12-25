import 'package:intl/intl.dart';

mixin DateTimeFormatMixin {
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce (${DateFormat('HH:mm').format(dateTime)})';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce (${DateFormat('HH:mm').format(dateTime)})';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce (${DateFormat('HH:mm').format(dateTime)})';
    } else {
      return 'Az önce (${DateFormat('HH:mm').format(dateTime)})';
    }
  }
}
