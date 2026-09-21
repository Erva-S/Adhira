import '../../core/enums/app_enums.dart';

/// Represents a pending action or deficiency requiring the student's attention.
class ApplicationAction {
  final String id;
  final String applicationId;
  final String userId;
  final String title;
  final String description;
  final ActionType actionType;
  final ActionStatus status;
  final DateTime? dueDate;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  const ApplicationAction({
    required this.id,
    required this.applicationId,
    required this.userId,
    required this.title,
    required this.description,
    required this.actionType,
    this.status = ActionStatus.open,
    this.dueDate,
    this.resolvedAt,
    required this.createdAt,
  });

  bool get isOpen => status == ActionStatus.open || status == ActionStatus.inProgress;

  ApplicationAction copyWith({
    String? id,
    String? applicationId,
    String? userId,
    String? title,
    String? description,
    ActionType? actionType,
    ActionStatus? status,
    DateTime? dueDate,
    DateTime? resolvedAt,
    DateTime? createdAt,
  }) {
    return ApplicationAction(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'user_id': userId,
      'title': title,
      'description': description,
      'action_type': actionType.name,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ApplicationAction.fromMap(Map<String, dynamic> map) {
    return ApplicationAction(
      id: map['id']?.toString() ?? '',
      applicationId: map['application_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      actionType: ActionType.values.firstWhere(
        (a) => a.name == map['action_type'] || a.label == map['action_type'],
        orElse: () => ActionType.general,
      ),
      status: ActionStatus.values.firstWhere(
        (s) => s.name == map['status'] || s.label == map['status'],
        orElse: () => ActionStatus.open,
      ),
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'].toString()) : null,
      resolvedAt: map['resolved_at'] != null ? DateTime.tryParse(map['resolved_at'].toString()) : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
