import '../../core/enums/app_enums.dart';

/// Represents a student's application for a scholarship.
class ScholarshipApplication {
  final String id;
  final String scholarshipId;
  final String studentId;
  final String scholarshipName;
  final ScholarshipType scholarshipType;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? lastUpdated;
  final String? academicYear;
  final double? requestedAmount;
  final double? sanctionedAmount;
  final String? applicationNumber;
  final String? remarks;
  final List<String> pendingActions;

  const ScholarshipApplication({
    required this.id,
    required this.scholarshipId,
    required this.studentId,
    required this.scholarshipName,
    required this.scholarshipType,
    required this.status,
    required this.appliedDate,
    this.lastUpdated,
    this.academicYear,
    this.requestedAmount,
    this.sanctionedAmount,
    this.applicationNumber,
    this.remarks,
    this.pendingActions = const [],
  });
}
