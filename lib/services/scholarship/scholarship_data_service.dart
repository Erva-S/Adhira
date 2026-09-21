import 'package:flutter/foundation.dart';
import '../../shared/models/models.dart';
import '../../core/enums/app_enums.dart';
import '../../repositories/repositories.dart';
import '../database/relational_data_store.dart';
import 'scholarship_mock_data.dart';

/// Centralized state management service for scholarship data.
///
/// Refactored to sit cleanly atop the Repository layer ([ScholarshipRepository],
/// [ApplicationRepository], [DocumentRepository], [PaymentRepository], [NotificationRepository]).
/// Enforces user-isolated data fetching and reactive UI updates across the entire application.
class ScholarshipDataService extends ChangeNotifier {
  final ScholarshipRepository _scholarshipRepo;
  final ApplicationRepository _applicationRepo;
  final DocumentRepository _documentRepo;
  final PaymentRepository _paymentRepo;
  final NotificationRepository _notificationRepo;

  // ── Internal State ─────────────────────────────────────────────
  String _currentUserId = RelationalDataStore.demoUserId;
  List<Scholarship> _schemes = [];
  List<ScholarshipApplication> _applications = [];
  List<ApplicationAction> _pendingActions = [];
  List<Document> _documents = [];
  List<Payment> _payments = [];
  List<NotificationItem> _notifications = [];
  List<ActivityItem> _recentActivity = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Constructor ────────────────────────────────────────────────
  ScholarshipDataService({
    ScholarshipRepository? scholarshipRepo,
    ApplicationRepository? applicationRepo,
    DocumentRepository? documentRepo,
    PaymentRepository? paymentRepo,
    NotificationRepository? notificationRepo,
    String? initialUserId,
  })  : _scholarshipRepo = scholarshipRepo ?? AppScholarshipRepository(),
        _applicationRepo = applicationRepo ?? AppApplicationRepository(),
        _documentRepo = documentRepo ?? AppDocumentRepository(),
        _paymentRepo = paymentRepo ?? AppPaymentRepository(),
        _notificationRepo = notificationRepo ?? AppNotificationRepository() {
    if (initialUserId != null && initialUserId.isNotEmpty) {
      _currentUserId = initialUserId;
    }
    // Synchronously prime from relational store for immediate first-frame rendering
    final store = RelationalDataStore();
    _schemes = store.getScholarships();
    _applications = store.getApplicationsForUser(_currentUserId);
    _pendingActions = store.getActionsForUser(_currentUserId);
    _documents = store.getDocumentsForUser(_currentUserId);
    _payments = store.getPaymentsForUser(_currentUserId);
    _notifications = store.getNotificationsForUser(_currentUserId);

    _loadInitialData();
  }

  // ── Getters ────────────────────────────────────────────────────
  String get currentUserId => _currentUserId;
  List<Scholarship> get schemes => List.unmodifiable(_schemes);
  List<ScholarshipApplication> get applications => List.unmodifiable(_applications);
  List<ApplicationAction> get pendingActions => List.unmodifiable(_pendingActions);
  List<Document> get documents => List.unmodifiable(_documents);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<ActivityItem> get recentActivity => List.unmodifiable(_recentActivity);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Derived Data ───────────────────────────────────────────────
  List<ScholarshipApplication> get activeApplications =>
      _applications.where((a) =>
          a.status != ApplicationStatus.rejected &&
          a.status != ApplicationStatus.withdrawn).toList();

  List<ScholarshipApplication> get completedApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.approved ||
          a.status == ApplicationStatus.sanctioned ||
          a.status == ApplicationStatus.disbursed).toList();

  List<ScholarshipApplication> get rejectedApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.rejected).toList();

  List<ScholarshipApplication> get draftApplications =>
      _applications.where((a) =>
          a.status == ApplicationStatus.draft).toList();

  List<Document> get reusableDocuments =>
      _documents.where((d) => d.status == DocumentStatus.verified).toList();

  int get totalApplied => _applications.length;

  int get activeCount => activeApplications
      .where((a) => a.status != ApplicationStatus.draft)
      .length;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  int get openActionsCount =>
      _pendingActions.where((a) => a.isOpen).length;

  double get totalDisbursed => _payments
      .where((p) => p.status == PaymentStatus.disbursed)
      .fold(0, (sum, p) => sum + p.amount);

  double get totalPending => _payments
      .where((p) => p.status != PaymentStatus.disbursed && p.status != PaymentStatus.failed)
      .fold(0, (sum, p) => sum + p.amount);

  double get totalSanctioned => _payments.fold(0, (sum, p) => sum + p.amount);

  // ── User Switching (Enforces Isolation) ────────────────────────
  Future<void> switchUser(String userId) async {
    if (_currentUserId == userId && _applications.isNotEmpty) return;
    _currentUserId = userId;
    await loadUserData(userId);
  }

  // ── Data Loading ───────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    await loadUserData(_currentUserId);
  }

  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUserId = userId;

      // Master data (public schemes)
      _schemes = await _scholarshipRepo.getScholarships();

      // User-specific isolated data
      _applications = await _applicationRepo.getApplicationsForUser(userId);
      _pendingActions = await _applicationRepo.getPendingActions(userId);
      _documents = await _documentRepo.getDocumentsForUser(userId);
      _payments = await _paymentRepo.getPaymentsForUser(userId);
      _notifications = await _notificationRepo.getNotificationsForUser(userId);

      // Recent activity
      _recentActivity = _applications.map((app) {
        return ActivityItem(
          title: 'Application for ${app.scholarshipName}',
          description: 'Current status: ${app.status.label} (${app.currentStage.label})',
          timestamp: app.appliedDate,
          type: ActivityType.application,
          applicationId: app.id,
        );
      }).toList();
    } catch (e) {
      _errorMessage = 'Failed to load scholarship records. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      return _applications.firstWhere(
        (a) => a.id == id || (id == 'app-001' && a.id == 'app-pms-2025-001'),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<ApplicationStatusHistory>> getStatusHistory(String applicationId) async {
    return _applicationRepo.getStatusHistory(applicationId);
  }

  List<Payment> getPaymentsForApplication(String applicationId) {
    return _payments.where((p) => p.applicationId == applicationId).toList();
  }

  List<ScholarshipApplication> getApplicationsByStatus(ApplicationStatus status) {
    return _applications.where((a) => a.status == status).toList();
  }

  bool hasAppliedForScheme(String scholarshipId) {
    return _applications.any((a) =>
        a.scholarshipId == scholarshipId &&
        a.status != ApplicationStatus.rejected &&
        a.status != ApplicationStatus.withdrawn);
  }

  // ── Actions ────────────────────────────────────────────────────

  /// Submit a new scholarship application with support for reusable documents.
  Future<ScholarshipApplication> submitApplication({
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
    required String academicYear,
    double? requestedAmount,
    String? remarks,
    List<String> reusedDocumentIds = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newApp = await _applicationRepo.submitApplication(
        userId: _currentUserId,
        scholarshipId: scholarshipId,
        scholarshipName: scholarshipName,
        scholarshipType: scholarshipType,
        academicYear: academicYear,
        requestedAmount: requestedAmount,
        remarks: remarks,
        reusedDocumentIds: reusedDocumentIds,
      );

      // Reload user data to maintain relational integrity
      await loadUserData(_currentUserId);
      return newApp;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save application as draft.
  void saveDraft({
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
  }) {
    final existingDraft = _applications.where((a) =>
        a.scholarshipId == scholarshipId &&
        a.status == ApplicationStatus.draft).toList();

    if (existingDraft.isNotEmpty) return;

    final newDraft = ScholarshipApplication(
      id: 'app-draft-${DateTime.now().millisecondsSinceEpoch}',
      scholarshipId: scholarshipId,
      studentId: _currentUserId,
      scholarshipName: scholarshipName,
      scholarshipType: scholarshipType,
      status: ApplicationStatus.draft,
      currentStage: ApplicationStage.application,
      appliedDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      applicationNumber: '${scholarshipType.shortCode}-DRAFT',
      remarks: 'Draft — complete form to submit',
      pendingActions: const ['Complete all required fields', 'Upload documents', 'Submit application'],
    );

    _applications.add(newDraft);
    notifyListeners();
  }

  /// Resolve a pending action / deficiency.
  Future<void> resolvePendingAction(String actionId) async {
    await _applicationRepo.resolveAction(actionId, _currentUserId);
    _pendingActions = await _applicationRepo.getPendingActions(_currentUserId);
    notifyListeners();
  }

  /// Mark notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationRepo.markAsRead(notificationId, _currentUserId);
    _notifications = await _notificationRepo.getNotificationsForUser(_currentUserId);
    notifyListeners();
  }

  /// Mark all notifications as read.
  Future<void> markAllNotificationsAsRead() async {
    await _notificationRepo.markAllAsRead(_currentUserId);
    _notifications = await _notificationRepo.getNotificationsForUser(_currentUserId);
    notifyListeners();
  }

  /// Upload a document to user's wallet.
  Future<Document> uploadDocument({
    required String name,
    required DocumentCategory category,
    String? documentType,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final doc = await _documentRepo.uploadDocument(
      userId: _currentUserId,
      name: name,
      category: category,
      documentType: documentType,
      fileName: fileName,
      bytes: bytes,
    );
    _documents = await _documentRepo.getDocumentsForUser(_currentUserId);
    notifyListeners();
    return doc;
  }

  /// Refresh data.
  void refreshData() {
    loadUserData(_currentUserId);
  }
}
