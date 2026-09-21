import '../../core/enums/app_enums.dart';

/// Represents a historical checkpoint in the lifecycle of a scholarship application.
/// Used to generate dynamic tracking timelines and audit trails.
class ApplicationStatusHistory {
  final String id;
  final String applicationId;
  final ApplicationStage stage;
  final VerificationStatus status;
  final String message;
  final String changedBy;
  final DateTime changedAt;

  const ApplicationStatusHistory({
    required this.id,
    required this.applicationId,
    required this.stage,
    required this.status,
    required this.message,
    this.changedBy = 'MoTA System',
    required this.changedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'stage': stage.name,
      'status': status.name,
      'message': message,
      'changed_by': changedBy,
      'changed_at': changedAt.toIso8601String(),
    };
  }

  factory ApplicationStatusHistory.fromMap(Map<String, dynamic> map) {
    return ApplicationStatusHistory(
      id: map['id']?.toString() ?? '',
      applicationId: map['application_id']?.toString() ?? '',
      stage: ApplicationStage.values.firstWhere(
        (s) => s.name == map['stage'] || s.label == map['stage'],
        orElse: () => ApplicationStage.application,
      ),
      status: VerificationStatus.values.firstWhere(
        (v) => v.name == map['status'] || v.label == map['status'],
        orElse: () => VerificationStatus.pending,
      ),
      message: map['message']?.toString() ?? '',
      changedBy: map['changed_by']?.toString() ?? 'System',
      changedAt: map['changed_at'] != null
          ? DateTime.tryParse(map['changed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
