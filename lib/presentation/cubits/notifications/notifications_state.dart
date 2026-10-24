import 'package:veyra/domain/entities/app_notification.dart';
import 'package:veyra/presentation/cubits/notifications/notifications_status.dart';

class NotificationsState {
  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}
