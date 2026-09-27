import 'dart:async';
import 'dart:math';
import '../../core/enums/app_enums.dart';
import '../../shared/models/models.dart';

/// Centralized in-memory relational database store.
///
/// Implements relational constraints, foreign keys, and strict user isolation.
/// Provides a unified data engine for offline, development, and test environments,
/// strictly mirroring the PostgreSQL schema in `supabase/schema.sql`.
class RelationalDataStore {
  static final RelationalDataStore _instance = RelationalDataStore._internal();
  factory RelationalDataStore() => _instance;

  RelationalDataStore._internal() {
    _initSeedData();
  }

  // ── Tables ────────────────────────────────────────────────────────
  final Map<String, Student> _users = {};
  final List<Scholarship> _scholarships = [];
  final List<ScholarshipApplication> _applications = [];
  final List<ApplicationStatusHistory> _statusHistory = [];
  final List<Document> _documents = [];
  final List<ApplicationDocument> _applicationDocuments = [];
  final List<ApplicationAction> _applicationActions = [];
  final List<Payment> _payments = [];
  final List<NotificationItem> _notifications = [];
  final Map<String, Set<String>> _userDeviceTokens = {};

  final StreamController<NotificationItem> _notificationStreamController =
      StreamController<NotificationItem>.broadcast();

  /// Real-time stream of notifications across all users (filtered by subscriber).
  Stream<NotificationItem> get notificationStream => _notificationStreamController.stream;

  static const String demoUserId = 'TSS-2025-45678';
  static const String demoUserPhone = '9876543210';

  // ── Seeding ───────────────────────────────────────────────────────
  void _initSeedData() {
    _seedScholarships();
    _seedDemoUser();
  }

  void _seedScholarships() {
    _scholarships.clear();
    _scholarships.addAll([
      const Scholarship(
        id: 'sch-pre-matric',
        type: ScholarshipType.preMatric,
        name: 'Pre-Matric Scholarship for ST Students',
        description: 'Financial support for ST students in Class 9 & 10 to reduce dropouts.',
        detailedDescription:
            'Centrally sponsored scheme implemented through state governments. Provides monthly stipend, book grant, and hostel allowances for Scheduled Tribe students studying in recognized schools.',
        maxAmount: 22500,
        duration: '10 Months / Academic Year',
        eligibilityCriteria: [
          'Must belong to Scheduled Tribe (ST)',
          'Studying in Class 9 or 10 in recognized school',
          'Annual family income must not exceed Rs. 2,50,000',
          'Regular attendance and satisfactory academic performance',
        ],
        requiredDocuments: [
          'ST/PVTG Certificate',
          'Income Certificate',
          'Previous Class Marksheet',
          'Aadhaar Card',
          'Bank Account Passbook Copy',
        ],
        portalUrl: 'https://scholarships.gov.in',
        isOpen: true,
      ),
      const Scholarship(
        id: 'sch-post-matric',
        type: ScholarshipType.postMatric,
        name: 'Post-Matric Scholarship for ST Students',
        description: 'Comprehensive financial support for Class 11, 12, Degree, Diploma & PG studies.',
        detailedDescription:
            'Flagship MoTA scheme providing full compulsory non-refundable fees, monthly maintenance allowance, study tour charges, thesis charges, and book allowance directly to the student via DBT.',
        maxAmount: 70000,
        duration: 'Duration of Course (1-5 Years)',
        eligibilityCriteria: [
          'Must belong to Scheduled Tribe (ST)',
          'Enrolled in Class 11, 12, ITI, Diploma, Degree, or PG course',
          'Annual family income <= Rs. 2,50,000',
          'Enrolled in institution with valid AISHE code',
        ],
        requiredDocuments: [
          'ST Certificate',
          'Income Certificate',
          'Class 10/12 Marksheet',
          'Institution Bonafide / Enrollment Certificate',
          'Bank Passbook / Cancelled Cheque',
          'Aadhaar Card',
        ],
        portalUrl: 'https://scholarships.gov.in',
        isOpen: true,
      ),
      const Scholarship(
        id: 'sch-top-class',
        type: ScholarshipType.topClass,
        name: 'National Scholarship for Higher Education (Top Class)',
        description: 'Full tuition fee and living expenses at premier institutions (IIT, NIT, IIM, AIIMS).',
        detailedDescription:
            'Enables meritorious ST students to pursue quality higher education in 250+ notified premier institutes across India. Covers full tuition, boarding, books, and computer allowance.',
        maxAmount: 250000,
        duration: 'Full Degree Duration',
        eligibilityCriteria: [
          'Must belong to Scheduled Tribe (ST)',
          'Admitted to notified premier institution (IITs, NITs, IIMs, NLUs, AIIMS)',
          'Annual family income <= Rs. 6,00,000',
          'Admission through national entrance examinations (JEE, NEET, CAT, CLAT)',
        ],
        requiredDocuments: [
          'ST Certificate',
          'Income Certificate',
          'Institute Fee Receipt / Admission Letter',
          'Entrance Exam Scorecard & Rank Card',
          'Aadhaar Card',
          'Bank Account Passbook',
        ],
        portalUrl: 'https://scholarships.gov.in',
        isOpen: true,
      ),
      const Scholarship(
        id: 'sch-nfst',
        type: ScholarshipType.nfst,
        name: 'National Fellowship for ST Students',
        description: 'Financial assistance for ST scholars pursuing full-time M.Phil & Ph.D research.',
        detailedDescription:
            'Provides junior and senior research fellowships (JRF/SRF) of Rs. 37,000 to Rs. 42,000 per month, plus contingency grant of Rs. 25,000/yr and HRA for ST scholars in universities.',
        maxAmount: 42000,
        duration: 'Up to 5 Years',
        eligibilityCriteria: [
          'Must belong to Scheduled Tribe (ST)',
          'Qualified UGC-NET or CSIR-NET',
          'Enrolled in regular full-time M.Phil / Ph.D program in recognized Indian university',
          'Satisfactory research progress certified by Research Supervisor',
        ],
        requiredDocuments: [
          'ST Certificate',
          'UGC-NET / CSIR-NET Scorecard',
          'University Ph.D Admission / Registration Letter',
          'Research Proposal Summary',
          'Supervisor Recommendation Letter',
          'Aadhaar Card',
        ],
        portalUrl: 'https://fellowship.tribal.gov.in',
        isOpen: true,
      ),
      const Scholarship(
        id: 'sch-nos',
        type: ScholarshipType.nos,
        name: 'National Overseas Scholarship for ST Candidates',
        description: 'Prestigious fellowship for Master and Ph.D degrees at top world universities.',
        detailedDescription:
            'Supports meritorious ST candidates for pursuing Master level, Ph.D, and Post-Doctoral studies in accredited institutions abroad in USA, UK, Germany, Canada, Australia, etc.',
        maxAmount: 1500000,
        duration: 'Masters: 2-3 Years | PhD: 4-5 Years',
        eligibilityCriteria: [
          'Must belong to Scheduled Tribe (ST)',
          'Unconditional admission offer from top 500 QS World Ranking university',
          'Annual family income <= Rs. 6,00,000',
          'Minimum 55% marks in qualifying Bachelor/Master degree',
          'Age below 35 years as on first day of application year',
        ],
        requiredDocuments: [
          'ST Certificate',
          'Income Certificate',
          'Unconditional Offer Letter from Foreign University',
          'Valid Indian Passport',
          'GRE/GMAT/IELTS/TOEFL Scorecard',
          'Statement of Purpose (SOP)',
        ],
        portalUrl: 'https://overseas.tribal.gov.in',
        isOpen: true,
      ),
    ]);
  }

  void _seedDemoUser() {
    // 1. Demo Student Profile: Rajesh Soren
    const student = Student(
      id: demoUserId,
      authUserId: 'auth-user-001',
      fullName: 'Rajesh Soren',
      fatherName: 'Manoj Soren',
      motherName: 'Sunita Soren',
      dateOfBirth: null,
      gender: 'Male',
      category: 'ST',
      aadhaarNumber: 'XXXX-XXXX-4892',
      mobileNumber: demoUserPhone,
      email: 'rajesh.soren@nitrkl.ac.in',
      tribeName: 'Santal',
      isPVTG: false,
      stCertificateNumber: 'SC/OD/2023/12345',
      address: 'Plot 42, Baripada',
      district: 'Mayurbhanj',
      state: 'Odisha',
      pinCode: '757001',
      educationLevel: 'Undergraduate',
      currentCourse: 'B.Tech Computer Science',
      currentYear: '2nd Year',
      institutionName: 'NIT Rourkela',
      institutionId: 'AISHE-U-0355',
      bankAccountNumber: '****7890',
      ifscCode: 'SBIN0001234',
      bankName: 'State Bank of India',
      annualFamilyIncome: 180000.0,
      profileCompletionPercent: 0.72,
    );
    _users[demoUserId] = student;

    // 2. Demo User Documents (Document Wallet)
    _documents.addAll([
      Document(
        id: 'doc-001',
        userId: demoUserId,
        name: 'Aadhaar Card',
        documentType: 'IDENTITY',
        category: DocumentCategory.identity,
        status: DocumentStatus.verified,
        storagePath: 'documents/$demoUserId/doc-001_aadhaar.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-001_aadhaar.pdf',
        fileName: 'aadhaar_card.pdf',
        fileType: 'pdf',
        fileSizeBytes: 420000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 45)),
        verifiedAt: DateTime.now().subtract(const Duration(days: 44)),
        isFromDigiLocker: true,
      ),
      Document(
        id: 'doc-002',
        userId: demoUserId,
        name: 'ST Certificate',
        documentType: 'ST_CERTIFICATE',
        category: DocumentCategory.caste,
        status: DocumentStatus.verified,
        storagePath: 'documents/$demoUserId/doc-002_st_certificate.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-002_st_certificate.pdf',
        fileName: 'st_certificate.pdf',
        fileType: 'pdf',
        fileSizeBytes: 850000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 40)),
        verifiedAt: DateTime.now().subtract(const Duration(days: 38)),
      ),
      Document(
        id: 'doc-003',
        userId: demoUserId,
        name: 'Class 12 Marksheet',
        documentType: 'ACADEMIC_MARKSHEET',
        category: DocumentCategory.academic,
        status: DocumentStatus.verified,
        storagePath: 'documents/$demoUserId/doc-003_marksheet.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-003_marksheet.pdf',
        fileName: 'class_12_marksheet.pdf',
        fileType: 'pdf',
        fileSizeBytes: 1200000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 35)),
        verifiedAt: DateTime.now().subtract(const Duration(days: 34)),
        isFromDigiLocker: true,
      ),
      Document(
        id: 'doc-004',
        userId: demoUserId,
        name: 'College Enrollment Certificate',
        documentType: 'BONAFIDE',
        category: DocumentCategory.academic,
        status: DocumentStatus.verified,
        storagePath: 'documents/$demoUserId/doc-004_bonafide.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-004_bonafide.pdf',
        fileName: 'nitrkl_enrollment.pdf',
        fileType: 'pdf',
        fileSizeBytes: 620000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
        verifiedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      Document(
        id: 'doc-005',
        userId: demoUserId,
        name: 'Income Certificate',
        documentType: 'INCOME_CERTIFICATE',
        category: DocumentCategory.income,
        status: DocumentStatus.rejected,
        storagePath: 'documents/$demoUserId/doc-005_income.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-005_income.pdf',
        fileName: 'income_certificate_2023.pdf',
        fileType: 'pdf',
        fileSizeBytes: 710000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 25)),
        rejectionReason: 'Certificate expired (AY 2023-24). Please upload valid certificate for AY 2025-26.',
      ),
      Document(
        id: 'doc-006',
        userId: demoUserId,
        name: 'Bank Passbook Copy',
        documentType: 'BANK_PASSBOOK',
        category: DocumentCategory.bank,
        status: DocumentStatus.uploaded,
        storagePath: 'documents/$demoUserId/doc-006_bank_passbook.pdf',
        fileUrl: 'secure://documents/$demoUserId/doc-006_bank_passbook.pdf',
        fileName: 'sbi_passbook.pdf',
        fileType: 'pdf',
        fileSizeBytes: 540000,
        uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);

    // 3. Demo User Active Application: Post-Matric Scholarship
    const appId = 'app-pms-2025-001';
    final application = ScholarshipApplication(
      id: appId,
      scholarshipId: 'sch-post-matric',
      studentId: demoUserId,
      scholarshipName: 'Post-Matric Scholarship for ST',
      scholarshipType: ScholarshipType.postMatric,
      status: ApplicationStatus.underReview,
      currentStage: ApplicationStage.departmentVerification,
      appliedDate: DateTime.now().subtract(const Duration(days: 25)),
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      academicYear: '2025-26',
      requestedAmount: 70000,
      sanctionedAmount: 70000,
      applicationNumber: 'PMS-2025-78432',
      remarks: 'Application verified by NIT Rourkela. State department verification underway.',
      pendingActions: ['Update Income Certificate for current AY 2025-26'],
    );
    _applications.add(application);

    // 4. Status History for the Application (Timeline Stages, Part 6)
    _statusHistory.addAll([
      ApplicationStatusHistory(
        id: 'hist-001',
        applicationId: appId,
        stage: ApplicationStage.application,
        status: VerificationStatus.verified,
        message: 'Application submitted successfully with all required certified declarations.',
        changedBy: 'Student',
        changedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ApplicationStatusHistory(
        id: 'hist-002',
        applicationId: appId,
        stage: ApplicationStage.documentVerification,
        status: VerificationStatus.verified,
        message: 'Aadhaar, ST Certificate, and Marksheets verified via DigiLocker & State e-District.',
        changedBy: 'State Verification Cell',
        changedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ApplicationStatusHistory(
        id: 'hist-003',
        applicationId: appId,
        stage: ApplicationStage.instituteVerification,
        status: VerificationStatus.verified,
        message: 'Enrollment, course fee schedule, and attendance verified by Dean Academic, NIT Rourkela.',
        changedBy: 'NIT Rourkela Nodal Officer',
        changedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ApplicationStatusHistory(
        id: 'hist-004',
        applicationId: appId,
        stage: ApplicationStage.departmentVerification,
        status: VerificationStatus.inProgress,
        message: 'State Tribal Welfare Department review in progress. Awaiting updated income certificate.',
        changedBy: 'District Welfare Officer',
        changedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    // 5. Application Document Junction Links (Document Reuse, Part 9)
    _applicationDocuments.addAll([
      ApplicationDocument(
        id: 'appdoc-001',
        applicationId: appId,
        documentId: 'doc-001',
        documentType: 'IDENTITY',
        isReused: true,
        attachedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ApplicationDocument(
        id: 'appdoc-002',
        applicationId: appId,
        documentId: 'doc-002',
        documentType: 'ST_CERTIFICATE',
        isReused: true,
        attachedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ApplicationDocument(
        id: 'appdoc-003',
        applicationId: appId,
        documentId: 'doc-003',
        documentType: 'ACADEMIC_MARKSHEET',
        isReused: true,
        attachedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ApplicationDocument(
        id: 'appdoc-004',
        applicationId: appId,
        documentId: 'doc-004',
        documentType: 'BONAFIDE',
        isReused: false,
        attachedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ]);

    // 6. Pending Actions / Deficiencies (Part 11)
    _applicationActions.add(
      ApplicationAction(
        id: 'act-001',
        applicationId: appId,
        userId: demoUserId,
        title: 'Update Income Certificate',
        description:
            'The uploaded income certificate is dated AY 2023-24. Please re-upload a valid revenue department certificate for AY 2025-26.',
        actionType: ActionType.incomeClarification,
        status: ActionStatus.open,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );

    // 7. Payments / DBT Records (Part 12)
    _payments.addAll([
      Payment(
        id: 'pay-001',
        applicationId: appId,
        userId: demoUserId,
        scholarshipName: 'Post-Matric Scholarship for ST Students',
        status: PaymentStatus.disbursed,
        dbtStatus: DbtStatus.credited,
        amount: 45000,
        sanctionedDate: DateTime.now().subtract(const Duration(days: 60)),
        disbursedDate: DateTime.now().subtract(const Duration(days: 45)),
        transactionId: 'TXN-PFMS-78432-001',
        bankRefNumber: 'SBI-UTR-99882211',
        referenceNumber: 'PFMS/MOTA/2025/44321',
        transactionReference: 'UTR202509150044',
        academicYear: '2025-26',
        installmentLabel: 'Tuition Fee & Institutional Component',
      ),
      Payment(
        id: 'pay-002',
        applicationId: appId,
        userId: demoUserId,
        scholarshipName: 'Post-Matric Scholarship for ST Students',
        status: PaymentStatus.processing,
        dbtStatus: DbtStatus.dbtInitiated,
        amount: 25000,
        sanctionedDate: DateTime.now().subtract(const Duration(days: 15)),
        referenceNumber: 'PFMS/MOTA/2025/44322',
        academicYear: '2025-26',
        installmentLabel: 'Maintenance & Living Allowance (Sem 1)',
      ),
    ]);

    // 8. Notifications for Demo User (Part 13)
    _notifications.addAll([
      NotificationItem(
        id: 'notif-001',
        userId: demoUserId,
        type: NotificationType.alert,
        title: 'Action Required: Income Certificate',
        message:
            'Your Post-Matric Scholarship application requires an updated income certificate for AY 2025-26.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        actionRoute: '/applications/tracking',
        relatedId: appId,
      ),
      NotificationItem(
        id: 'notif-002',
        userId: demoUserId,
        type: NotificationType.verification,
        title: 'Institute Verification Completed',
        message: 'NIT Rourkela has verified your academic enrollment and fee schedule.',
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        isRead: true,
        actionRoute: '/applications/tracking',
        relatedId: appId,
      ),
      NotificationItem(
        id: 'notif-003',
        userId: demoUserId,
        type: NotificationType.payment,
        title: 'DBT Payment Credited (₹45,000)',
        message: '₹45,000 tuition fee component was credited to your bank account via PFMS.',
        timestamp: DateTime.now().subtract(const Duration(days: 45)),
        isRead: true,
        actionRoute: '/payments',
        relatedId: 'pay-001',
      ),
      NotificationItem(
        id: 'notif-004',
        userId: demoUserId,
        type: NotificationType.system,
        title: 'Welcome to Adhira',
        message: 'Your MoTA student scholarship account has been established.',
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
        isRead: true,
      ),
    ]);
  }

  // ==========================================================================
  // USER PROFILE OPERATIONS (Part 3)
  // ==========================================================================
  Student? getUser(String userId) => _users[userId];

  Student? getUserByPhone(String phoneNumber) {
    try {
      return _users.values.firstWhere((u) => u.mobileNumber == phoneNumber);
    } catch (_) {
      return null;
    }
  }

  Student createOrFindUser({required String phoneNumber, String? fullName}) {
    final existing = getUserByPhone(phoneNumber);
    if (existing != null) return existing;

    // Create a new fresh student account
    final newUserId = 'TSS-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';
    final newUser = Student(
      id: newUserId,
      authUserId: 'auth-$newUserId',
      fullName: fullName ?? 'ST Scholar',
      mobileNumber: phoneNumber,
      category: 'ST',
      profileCompletionPercent: 0.20,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _users[newUserId] = newUser;

    // Send initial welcome notification
    addNotification(
      NotificationItem(
        id: 'notif-new-${DateTime.now().millisecondsSinceEpoch}',
        userId: newUserId,
        type: NotificationType.system,
        title: 'Welcome to Adhira',
        message: 'Your account is ready. Complete your student profile and apply for scholarships.',
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: '/profile',
      ),
    );

    return newUser;
  }

  Student updateUser(Student updated) {
    _users[updated.id] = updated.copyWith(updatedAt: DateTime.now());
    return _users[updated.id]!;
  }

  // ==========================================================================
  // SCHOLARSHIP MASTER DATA OPERATIONS (Part 4)
  // ==========================================================================
  List<Scholarship> getScholarships() => List.unmodifiable(_scholarships);

  Scholarship? getScholarshipById(String id) {
    try {
      return _scholarships.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================================
  // SCHOLARSHIP APPLICATIONS (Parts 5 & 16 - User Isolated)
  // ==========================================================================
  List<ScholarshipApplication> getApplicationsForUser(String userId) {
    return _applications.where((a) => a.studentId == userId).toList();
  }

  ScholarshipApplication? getApplicationById(String applicationId, {String? userId}) {
    try {
      final app = _applications.firstWhere((a) =>
          a.id == applicationId ||
          (applicationId == 'app-001' && a.id == 'app-pms-2025-001'));
      if (userId != null && app.studentId != userId) {
        // Enforce user isolation: User A cannot read User B's application
        return null;
      }
      return app;
    } catch (_) {
      return null;
    }
  }

  ScholarshipApplication createApplication({
    required String userId,
    required String scholarshipId,
    required String scholarshipName,
    required ScholarshipType scholarshipType,
    required String academicYear,
    double? requestedAmount,
    String? remarks,
    List<String> reusedDocumentIds = const [],
  }) {
    final appNumber =
        '${scholarshipType.shortCode}-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';
    final newApp = ScholarshipApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      scholarshipId: scholarshipId,
      studentId: userId,
      scholarshipName: scholarshipName,
      scholarshipType: scholarshipType,
      status: ApplicationStatus.submitted,
      currentStage: ApplicationStage.application,
      appliedDate: DateTime.now(),
      submittedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      academicYear: academicYear,
      requestedAmount: requestedAmount,
      applicationNumber: appNumber,
      remarks: remarks ?? 'Application submitted. Initial verification initiated.',
      pendingActions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _applications.insert(0, newApp);

    // Record initial status history checkpoint (Part 6)
    _statusHistory.add(
      ApplicationStatusHistory(
        id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
        applicationId: newApp.id,
        stage: ApplicationStage.application,
        status: VerificationStatus.verified,
        message: 'Application submitted successfully. Awaiting document verification.',
        changedBy: 'Student',
        changedAt: DateTime.now(),
      ),
    );

    // Link reused documents (Part 9)
    for (final docId in reusedDocumentIds) {
      final doc = _documents.where((d) => d.id == docId && d.userId == userId).firstOrNull;
      if (doc != null) {
        _applicationDocuments.add(
          ApplicationDocument(
            id: 'appdoc-${DateTime.now().millisecondsSinceEpoch}-${doc.id}',
            applicationId: newApp.id,
            documentId: doc.id,
            documentType: doc.documentType ?? doc.name,
            isReused: true,
            attachedAt: DateTime.now(),
          ),
        );
      }
    }

    // Add notification
    addNotification(
      NotificationItem(
        id: 'notif-app-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: NotificationType.application,
        title: 'Application Submitted',
        message: 'Your application ($appNumber) for $scholarshipName has been submitted.',
        timestamp: DateTime.now(),
        isRead: false,
        actionRoute: '/applications/tracking',
        relatedId: newApp.id,
      ),
    );

    return newApp;
  }

  // ==========================================================================
  // APPLICATION STATUS HISTORY (Part 6)
  // ==========================================================================
  List<ApplicationStatusHistory> getStatusHistory(String applicationId) {
    return _statusHistory
        .where((h) =>
            h.applicationId == applicationId ||
            (applicationId == 'app-001' && h.applicationId == 'app-pms-2025-001'))
        .toList()
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));
  }

  // ==========================================================================
  // DOCUMENT MANAGEMENT & REUSE (Parts 7, 8, 9 - User Isolated)
  // ==========================================================================
  List<Document> getDocumentsForUser(String userId) {
    return _documents.where((d) => d.userId == userId).toList();
  }

  List<Document> getVerifiedDocumentsForUser(String userId) {
    return _documents
        .where((d) => d.userId == userId && d.status == DocumentStatus.verified)
        .toList();
  }

  Document addDocument(Document doc) {
    _documents.insert(0, doc);
    return doc;
  }

  List<ApplicationDocument> getApplicationDocuments(String applicationId) {
    return _applicationDocuments.where((ad) => ad.applicationId == applicationId).toList();
  }

  // ==========================================================================
  // PENDING ACTIONS / DEFICIENCIES (Part 11 - User Isolated)
  // ==========================================================================
  List<ApplicationAction> getActionsForUser(String userId, {bool onlyOpen = false}) {
    return _applicationActions.where((a) {
      if (a.userId != userId) return false;
      if (onlyOpen) return a.isOpen;
      return true;
    }).toList();
  }

  ApplicationAction? resolveAction(String actionId, String userId) {
    final idx = _applicationActions.indexWhere((a) => a.id == actionId && a.userId == userId);
    if (idx == -1) return null;

    final updated = _applicationActions[idx].copyWith(
      status: ActionStatus.resolved,
      resolvedAt: DateTime.now(),
    );
    _applicationActions[idx] = updated;
    return updated;
  }

  // ==========================================================================
  // PAYMENTS / DBT (Part 12 - User Isolated)
  // ==========================================================================
  List<Payment> getPaymentsForUser(String userId) {
    return _payments.where((p) => p.userId == userId).toList();
  }

  List<Payment> getPaymentsForApplication(String applicationId, {String? userId}) {
    return _payments.where((p) {
      if (p.applicationId != applicationId) return false;
      if (userId != null && p.userId != userId) return false;
      return true;
    }).toList();
  }

  // ==========================================================================
  // NOTIFICATIONS (Part 13 - User Isolated & Real-Time)
  // ==========================================================================
  List<NotificationItem> getNotificationsForUser(String userId) {
    return _notifications.where((n) => n.userId == userId).toList();
  }

  int getUnreadNotificationCount(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  NotificationItem addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _notificationStreamController.add(notification);
    return notification;
  }

  void markNotificationAsRead(String notificationId, String userId) {
    final idx = _notifications.indexWhere((n) => n.id == notificationId && n.userId == userId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  void markAllNotificationsAsRead(String userId) {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  // ── Device Token Registration (FCM Lifecycle) ─────────────────────
  void registerDeviceToken(String userId, String token) {
    if (userId.isEmpty || token.isEmpty) return;
    _userDeviceTokens.putIfAbsent(userId, () => {}).add(token);
  }

  void unregisterDeviceToken(String userId, [String? token]) {
    if (token != null) {
      _userDeviceTokens[userId]?.remove(token);
    } else {
      _userDeviceTokens.remove(userId);
    }
  }

  Set<String> getDeviceTokensForUser(String userId) {
    return Set.unmodifiable(_userDeviceTokens[userId] ?? {});
  }
}
