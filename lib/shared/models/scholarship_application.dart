import '../../core/enums/app_enums.dart';

/// Represents a student's application for a scholarship.
class ScholarshipApplication {
  final String id;
  final String scholarshipId;
  final String studentId; // Relational foreign key to users.id
  final String scholarshipName;
  final ScholarshipType scholarshipType;
  final ApplicationStatus status;
  final ApplicationStage currentStage;
  final DateTime appliedDate;
  final DateTime? lastUpdated;
  final String? academicYear;
  final double? requestedAmount;
  final double? sanctionedAmount;
  final String? applicationNumber;
  final String? remarks;
  final List<String> pendingActions;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScholarshipApplication({
    required this.id,
    required this.scholarshipId,
    required this.studentId,
    required this.scholarshipName,
    required this.scholarshipType,
    required this.status,
    this.currentStage = ApplicationStage.application,
    required this.appliedDate,
    this.lastUpdated,
    this.academicYear,
    this.requestedAmount,
    this.sanctionedAmount,
    this.applicationNumber,
    this.remarks,
    this.pendingActions = const [],
    this.submittedAt,
    this.createdAt,
    this.updatedAt,
  });

  ScholarshipApplication copyWith({
    String? id,
    String? scholarshipId,
    String? studentId,
    String? scholarshipName,
    ScholarshipType? scholarshipType,
    ApplicationStatus? status,
    ApplicationStage? currentStage,
    DateTime? appliedDate,
    DateTime? lastUpdated,
    String? academicYear,
    double? requestedAmount,
    double? sanctionedAmount,
    String? applicationNumber,
    String? remarks,
    List<String>? pendingActions,
    DateTime? submittedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScholarshipApplication(
      id: id ?? this.id,
      scholarshipId: scholarshipId ?? this.scholarshipId,
      studentId: studentId ?? this.studentId,
      scholarshipName: scholarshipName ?? this.scholarshipName,
      scholarshipType: scholarshipType ?? this.scholarshipType,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      appliedDate: appliedDate ?? this.appliedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      academicYear: academicYear ?? this.academicYear,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      sanctionedAmount: sanctionedAmount ?? this.sanctionedAmount,
      applicationNumber: applicationNumber ?? this.applicationNumber,
      remarks: remarks ?? this.remarks,
      pendingActions: pendingActions ?? this.pendingActions,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_number': applicationNumber,
      'user_id': studentId,
      'scholarship_id': scholarshipId,
      'scholarship_name': scholarshipName,
      'scholarship_type': scholarshipType.name,
      'academic_year': academicYear,
      'status': status.name,
      'current_stage': currentStage.name,
      'requested_amount': requestedAmount,
      'sanctioned_amount': sanctionedAmount,
      'remarks': remarks,
      'pending_actions': pendingActions,
      'applied_date': appliedDate.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ScholarshipApplication.fromMap(Map<String, dynamic> map) {
    return ScholarshipApplication(
      id: map['id']?.toString() ?? '',
      scholarshipId: map['scholarship_id']?.toString() ?? '',
      studentId: map['user_id']?.toString() ?? map['student_id']?.toString() ?? '',
      scholarshipName: map['scholarship_name']?.toString() ?? 'Scholarship',
      scholarshipType: ScholarshipType.values.firstWhere(
        (t) => t.name == map['scholarship_type'] || t.shortCode == map['scholarship_type'],
        orElse: () => ScholarshipType.postMatric,
      ),
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == map['status'] || s.label == map['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      currentStage: ApplicationStage.values.firstWhere(
        (s) => s.name == map['current_stage'] || s.label == map['current_stage'],
        orElse: () => ApplicationStage.application,
      ),
      appliedDate: map['applied_date'] != null
          ? DateTime.tryParse(map['applied_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastUpdated: map['last_updated'] != null ? DateTime.tryParse(map['last_updated'].toString()) : null,
      academicYear: map['academic_year']?.toString(),
      requestedAmount: (map['requested_amount'] as num?)?.toDouble(),
      sanctionedAmount: (map['sanctioned_amount'] as num?)?.toDouble(),
      applicationNumber: map['application_number']?.toString(),
      remarks: map['remarks']?.toString(),
      pendingActions: (map['pending_actions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      submittedAt: map['submitted_at'] != null ? DateTime.tryParse(map['submitted_at'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }
}
