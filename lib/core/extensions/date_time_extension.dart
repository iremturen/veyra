import 'package:veyra/app/common/constants/app_strings.dart';

extension DateTimeFormatting on DateTime {
  /// Formats the date into a relative time string (e.g., 'Just now', '5m', '2h', '3d', or 'dd/MM/yyyy').
  String get timeAgo {
    final elapsed = DateTime.now().difference(this);
    if (elapsed.inMinutes < 1) return AppStrings.justNow;
    if (elapsed.inHours < 1) return '${elapsed.inMinutes}m';
    if (elapsed.inDays < 1) return '${elapsed.inHours}h';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d';
    return '$day/$month/$year';
  }
}
