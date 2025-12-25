import 'package:intl/intl.dart';

mixin RouteFormatMixin {
  String formatRouteDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  String formatRouteDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }
    return '${minutes}dk';
  }
}
