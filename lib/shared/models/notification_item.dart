import '../../core/enums/app_enums.dart';

/// Represents a notification sent to the student.
class NotificationItem {
  final String id;
  final String? userId; // Foreign key to users.id
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute; // deep-link to relevant page
  final String? relatedId; // application/document/payment ID

  const NotificationItem({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.relatedId,
  });

  NotificationItem copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
    String? relatedId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'action_route': actionRoute,
      'related_id': relatedId,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'] || t.label == map['type'],
        orElse: () => NotificationType.system,
      ),
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['is_read'] == true,
      actionRoute: map['action_route']?.toString(),
      relatedId: map['related_id']?.toString(),
    );
  }
}
