import '../../core/enums/app_enums.dart';

/// Represents a notification sent to the student.
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute; // deep-link to relevant page
  final String? relatedId; // application/document/payment ID

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.relatedId,
  });
}
