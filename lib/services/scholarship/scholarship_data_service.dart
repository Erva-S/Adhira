import 'package:flutter/foundation.dart';
import '../../shared/models/models.dart';
import '../../core/enums/app_enums.dart';
import 'scholarship_mock_data.dart';

/// Centralized state management service for scholarship data.
///
/// Uses [ChangeNotifier] so it can be provided via [Provider] and
/// UI rebuilds automatically when data changes.
class ScholarshipDataService extends ChangeNotifier {
  // ── Internal State ─────────────────────────────────────────────
  List<Scholarship> _schemes = [];
  List<ScholarshipApplication> _applications = [];
  List<Payment> _payments = [];
  List<ActivityItem> _recentActivity = [];
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────
  List<Scholarship> get schemes => List.unmodifiable(_schemes);
  List<ScholarshipApplication> get applications => List.unmodifiable(_applications);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<ActivityItem> get recentActivity => List.unmodifiable(_recentActivity);
  bool get isLoading => _isLoading;

  // ── Derived Data ───────────────────────────────────────────────
  List<ScholarshipApplication> get activeApplications =>
      _applications.where((a) =>
          a.status != ApplicationStatus.rejected &&
          a.status != ApplicationStatus.withdrawn).toList();

  List<ScholarshipApplication> get completedApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.approved ||
          a.status == ApplicationStatus.sanctioned).toList();

  List<ScholarshipApplication> get rejectedApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.rejected).toList();

  List<ScholarshipApplication> get draftApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.draft).toList();

  int get totalApplied => _applications.length;

  int get activeCount => activeApplications
      .where((a) => a.status != ApplicationStatus.draft)
      .length;

  double get totalDisbursed => _payments
      .where((p) => p.status == PaymentStatus.disbursed)
      .fold(0, (sum, p) => sum + p.amount);

  double get totalPending => _payments
      .where((p) => p.status != PaymentStatus.disbursed && p.status != PaymentStatus.failed)
      .fold(0, (sum, p) => sum + p.amount);

  double get totalSanctioned => _payments.fold(0, (sum, p) => sum + p.amount);

  // ── Initialization ─────────────────────────────────────────────
  ScholarshipDataService() {
    _loadMockData();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay-free for now (mock data)
    _schemes = List.from(ScholarshipMockData.schemes);
    _applications = List.from(ScholarshipMockData.applications);
    _payments = List.from(ScholarshipMockData.payments);
    _recentActivity = List.from(ScholarshipMockData.recentActivity);

    _isLoading = false;
    notifyListeners();
  }

  // ── Queries ────────────────────────────────────────────────────
  Scholarship? getScholarshipById(String id) {
    try {
      return _schemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Scholarship? getScholarshipByType(ScholarshipType type) {
    try {
      return _schemes.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  ScholarshipApplication? getApplicationById(String id) {
    try {
      return _applications.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Payment> getPaymentsForApplication(String applicationId) {
    return _payments.where((p) => p.applicationId == applicationId).toList();
  }

  List<ScholarshipApplication> getApplicationsByStatus(ApplicationStatus status) {
    return _applications.where((a) => a.status == status).toList();
  }

  /// Check if the student has already applied (active/draft) for a given scheme.
  bool hasAppliedForScheme(String scholarshipId) {
    return _applications.any((a) =>
        a.scholarshipId == scholarshipId &&
        a.status != ApplicationStatus.rejected &&
        a.status != ApplicationStatus.withdrawn);
  }

  // ── Actions ────────────────────────────────────────────────────

  /// Submit a new scholarship application.
  void submitApplication({
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
    required String academicYear,
    double? requestedAmount,
  }) {
    final appNumber = '${scholarshipType.shortCode}-${DateTime.now().year}-${(_applications.length + 1).toString().padLeft(5, '0')}';
    final newApp = ScholarshipApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      scholarshipId: scholarshipId,
      studentId: 'student-001',
      scholarshipName: scholarshipName,
      scholarshipType: scholarshipType,
      status: ApplicationStatus.submitted,
      appliedDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      academicYear: academicYear,
      requestedAmount: requestedAmount,
      applicationNumber: appNumber,
      remarks: 'Application submitted. Awaiting initial review.',
      pendingActions: ['Document verification pending'],
    );

    _applications.insert(0, newApp);

    _recentActivity.insert(0, ActivityItem(
      title: 'Application Submitted',
      description: '$scholarshipName application submitted successfully.',
      timestamp: DateTime.now(),
      type: ActivityType.application,
      applicationId: newApp.id,
    ));

    notifyListeners();
  }

  /// Save application as draft.
  void saveDraft({
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
  }) {
    // Check if a draft already exists for this scheme
    final existingDraft = _applications.where((a) =>
        a.scholarshipId == scholarshipId &&
        a.status == ApplicationStatus.draft).toList();

    if (existingDraft.isNotEmpty) {
      // Update existing draft
      return;
    }

    final newDraft = ScholarshipApplication(
      id: 'app-draft-${DateTime.now().millisecondsSinceEpoch}',
      scholarshipId: scholarshipId,
      studentId: 'student-001',
      scholarshipName: scholarshipName,
      scholarshipType: scholarshipType,
      status: ApplicationStatus.draft,
      appliedDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      applicationNumber: '${scholarshipType.shortCode}-DRAFT',
      remarks: 'Draft — complete form to submit',
      pendingActions: ['Complete all required fields', 'Upload documents', 'Submit application'],
    );

    _applications.add(newDraft);

    _recentActivity.insert(0, ActivityItem(
      title: 'Draft Saved',
      description: '$scholarshipName application draft saved.',
      timestamp: DateTime.now(),
      type: ActivityType.application,
      applicationId: newDraft.id,
    ));

    notifyListeners();
  }

  /// Refresh data (simulate API call).
  void refreshData() {
    _loadMockData();
  }
}
