import '../../shared/models/models.dart';
import '../../core/enums/app_enums.dart';

/// Centralized mock data for all scholarship-related entities.
/// In production, this would be replaced by API calls.
class ScholarshipMockData {
  ScholarshipMockData._();

  // ── Scholarship Schemes ────────────────────────────────────────
  static final List<Scholarship> schemes = [
    Scholarship(
      id: 'sch-pre-matric',
      type: ScholarshipType.preMatric,
      name: 'Pre-Matric Scholarship for ST Students',
      description:
          'Financial assistance for ST students studying in classes 9 and 10 to reduce dropout rates and encourage tribal youth to continue education.',
      detailedDescription:
          'The Pre-Matric Scholarship scheme is implemented by the Ministry of Tribal Affairs to provide financial support to Scheduled Tribe students at pre-matric level. '
          'The objective is to minimize dropout rates and incentivize parents to send their children to school. '
          'It covers maintenance allowances, books, and ad-hoc grants for tribal students studying in recognized institutions.',
      maxAmount: 10000,
      duration: '1 Academic Year',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must be studying in Class 9 or Class 10',
        'Must be enrolled in a government or recognized school',
        'Family annual income should not exceed ₹2.50 Lakh',
        'Must have minimum 50% attendance',
      ],
      requiredDocuments: [
        'ST/Caste Certificate',
        'Income Certificate',
        'School Enrollment Certificate',
        'Aadhaar Card',
        'Bank Passbook',
        'Passport Photo',
      ],
      applicationDeadline: DateTime(2025, 12, 31),
      isOpen: true,
      portalUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'sch-post-matric',
      type: ScholarshipType.postMatric,
      name: 'Post-Matric Scholarship for ST Students',
      description:
          'Support for ST students pursuing post-matriculation courses including professional and technical courses.',
      detailedDescription:
          'The Post-Matric Scholarship is the flagship scheme of the Ministry of Tribal Affairs (MoTA), Government of India. '
          'It provides comprehensive financial support to ST students studying at post-matriculation or post-secondary stages to enable them to complete their education. '
          'The scheme covers tuition fees, maintenance allowances, study tour charges, thesis typing/printing charges, and book allowance.',
      maxAmount: 130000,
      duration: 'Duration of the Course',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must be enrolled in a recognized post-matric or post-secondary course',
        'Family annual income must not exceed ₹2.50 Lakh',
        'Must hold a valid Aadhaar-linked bank account',
        'Must have cleared the qualifying examination',
      ],
      requiredDocuments: [
        'ST/Caste Certificate',
        'Income Certificate',
        'Previous Year Marksheet',
        'Institution Enrollment Certificate',
        'Aadhaar Card',
        'Bank Passbook',
        'Passport Photo',
        'Domicile Certificate',
      ],
      applicationDeadline: DateTime(2026, 1, 31),
      isOpen: true,
      portalUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'sch-top-class',
      type: ScholarshipType.topClass,
      name: 'Top Class Education for ST Students',
      description:
          'Full financial support for ST students admitted to top institutions like IITs, IIMs, NITs, AIIMS, and other premier institutes.',
      detailedDescription:
          'The Top Class Education scheme provides comprehensive support to ST students admitted in notified premier institutions. '
          'It covers full tuition fees, living expenses, book allowance, computer/laptop allowance, and other academic needs. '
          'The scheme aims to ensure that deserving tribal students are not deprived of quality education due to financial constraints.',
      maxAmount: 500000,
      duration: 'Duration of the Course',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must be admitted to a notified top-class institution',
        'Family annual income must not exceed ₹6.00 Lakh',
        'Must have cleared the qualifying entrance examination',
        'Must maintain minimum CGPA/percentage as per institution norms',
      ],
      requiredDocuments: [
        'ST/Caste Certificate',
        'Income Certificate',
        'Admission Letter from Institution',
        'Entrance Exam Scorecard',
        'Aadhaar Card',
        'Bank Passbook',
        'Passport Photo',
        'Domicile Certificate',
      ],
      applicationDeadline: DateTime(2026, 2, 28),
      isOpen: true,
      portalUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'sch-nfst',
      type: ScholarshipType.nfst,
      name: 'National Fellowship for ST Students (NFST)',
      description:
          'Fellowship for ST students pursuing M.Phil and Ph.D in universities, colleges, and institutions recognized by UGC.',
      detailedDescription:
          'The National Fellowship for Scheduled Tribe Students (NFST) provides financial assistance to ST students for pursuing higher education leading to M.Phil/Ph.D degrees. '
          'The fellowship amount is at par with UGC fellowships. It includes monthly fellowship, contingency grant, HRA, '
          'escort/reader assistance for PwD candidates, and other benefits as per UGC norms.',
      maxAmount: 420000,
      duration: 'Up to 5 Years',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must have qualified NET/JRF or equivalent examination',
        'Must be admitted to M.Phil/Ph.D program in a UGC-recognized university',
        'Family annual income must not exceed ₹6.00 Lakh',
        'Age should not exceed 35 years at the time of application',
      ],
      requiredDocuments: [
        'ST/Caste Certificate',
        'Income Certificate',
        'NET/JRF Scorecard',
        'Ph.D Admission Letter',
        'Research Proposal',
        'Aadhaar Card',
        'Bank Passbook',
        'Passport Photo',
      ],
      applicationDeadline: DateTime(2026, 3, 15),
      isOpen: true,
      portalUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'sch-nos',
      type: ScholarshipType.nos,
      name: 'National Overseas Scholarship for ST Students',
      description:
          'Support for ST students to study abroad at Masters and Ph.D level in accredited institutions worldwide.',
      detailedDescription:
          'The National Overseas Scholarship (NOS) provides financial assistance to selected ST students for pursuing Masters and Ph.D level courses abroad. '
          'It covers tuition fees, maintenance allowance, contingency & equipment allowance, visa fees, '
          'air passage, and insurance. Only 20 awards are made each year, making it highly competitive.',
      maxAmount: 2000000,
      duration: 'Duration of the Course (max 4 years)',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must have secured admission in a top-500 QS-ranked foreign university',
        'Family annual income must not exceed ₹6.00 Lakh',
        'Must hold a valid passport',
        'Age should not exceed 35 years at the time of application',
        'Must have minimum 60% in qualifying examination',
      ],
      requiredDocuments: [
        'ST/Caste Certificate',
        'Income Certificate',
        'Foreign University Admission Offer',
        'Valid Passport',
        'GRE/GMAT/IELTS/TOEFL Scorecard',
        'Aadhaar Card',
        'Bank Passbook',
        'Passport Photo',
        'Statement of Purpose',
      ],
      applicationDeadline: DateTime(2026, 4, 30),
      isOpen: true,
      portalUrl: 'https://scholarships.gov.in',
    ),
  ];

  // ── Applications ───────────────────────────────────────────────
  static final List<ScholarshipApplication> applications = [
    ScholarshipApplication(
      id: 'app-001',
      scholarshipId: 'sch-post-matric',
      studentId: 'student-001',
      scholarshipName: 'Post-Matric Scholarship for ST',
      scholarshipType: ScholarshipType.postMatric,
      status: ApplicationStatus.underReview,
      appliedDate: DateTime(2025, 8, 15),
      lastUpdated: DateTime(2025, 9, 18),
      academicYear: '2025-26',
      requestedAmount: 70000,
      sanctionedAmount: 70000,
      applicationNumber: 'PMS-2025-78432',
      remarks: 'ST certificate verification in progress',
      pendingActions: ['Upload updated income certificate', 'Verify bank details'],
    ),
    ScholarshipApplication(
      id: 'app-002',
      scholarshipId: 'sch-pre-matric',
      studentId: 'student-001',
      scholarshipName: 'Pre-Matric Scholarship for ST',
      scholarshipType: ScholarshipType.preMatric,
      status: ApplicationStatus.approved,
      appliedDate: DateTime(2024, 7, 20),
      lastUpdated: DateTime(2024, 10, 5),
      academicYear: '2024-25',
      requestedAmount: 10000,
      sanctionedAmount: 10000,
      applicationNumber: 'PMS-PRE-2024-32156',
      remarks: 'Application approved. Amount disbursed.',
      pendingActions: [],
    ),
    ScholarshipApplication(
      id: 'app-003',
      scholarshipId: 'sch-top-class',
      studentId: 'student-001',
      scholarshipName: 'Top Class Education for ST',
      scholarshipType: ScholarshipType.topClass,
      status: ApplicationStatus.draft,
      appliedDate: DateTime(2025, 9, 10),
      lastUpdated: DateTime(2025, 9, 10),
      academicYear: '2025-26',
      requestedAmount: 250000,
      applicationNumber: 'TCE-2025-DRAFT',
      remarks: 'Draft — complete form to submit',
      pendingActions: ['Complete education details', 'Upload admission letter', 'Submit application'],
    ),
  ];

  // ── Payments ──────────────────────────────────────────────────
  static final List<Payment> payments = [
    Payment(
      id: 'pay-001',
      applicationId: 'app-001',
      scholarshipName: 'Post-Matric Scholarship',
      status: PaymentStatus.disbursed,
      amount: 25000,
      sanctionedDate: DateTime(2025, 9, 1),
      disbursedDate: DateTime(2025, 9, 15),
      transactionId: 'TXN-78432-001',
      bankRefNumber: 'NEFT-202509150012',
      academicYear: '2025-26',
      installmentLabel: 'Tuition Fee — Semester 1',
    ),
    Payment(
      id: 'pay-002',
      applicationId: 'app-001',
      scholarshipName: 'Post-Matric Scholarship',
      status: PaymentStatus.disbursed,
      amount: 20000,
      sanctionedDate: DateTime(2025, 9, 1),
      disbursedDate: DateTime(2025, 9, 20),
      transactionId: 'TXN-78432-002',
      bankRefNumber: 'NEFT-202509200045',
      academicYear: '2025-26',
      installmentLabel: 'Maintenance Allowance — Semester 1',
    ),
    Payment(
      id: 'pay-003',
      applicationId: 'app-001',
      scholarshipName: 'Post-Matric Scholarship',
      status: PaymentStatus.pending,
      amount: 25000,
      sanctionedDate: DateTime(2025, 9, 1),
      academicYear: '2025-26',
      installmentLabel: 'Tuition Fee — Semester 2',
    ),
    Payment(
      id: 'pay-004',
      applicationId: 'app-002',
      scholarshipName: 'Pre-Matric Scholarship',
      status: PaymentStatus.disbursed,
      amount: 10000,
      sanctionedDate: DateTime(2024, 10, 10),
      disbursedDate: DateTime(2024, 10, 25),
      transactionId: 'TXN-32156-001',
      bankRefNumber: 'NEFT-202410250078',
      academicYear: '2024-25',
      installmentLabel: 'Full Year Maintenance',
    ),
  ];

  // ── Recent Activity Feed ──────────────────────────────────────
  static final List<ActivityItem> recentActivity = [
    ActivityItem(
      title: 'ST Certificate Verification Started',
      description: 'Your ST certificate is under review by the district office.',
      timestamp: DateTime(2025, 9, 18, 14, 30),
      type: ActivityType.verification,
      applicationId: 'app-001',
    ),
    ActivityItem(
      title: 'Tuition Fee Disbursed',
      description: '₹25,000 transferred to your linked bank account.',
      timestamp: DateTime(2025, 9, 15, 10, 15),
      type: ActivityType.payment,
      applicationId: 'app-001',
    ),
    ActivityItem(
      title: 'Maintenance Allowance Disbursed',
      description: '₹20,000 transferred to your linked bank account.',
      timestamp: DateTime(2025, 9, 20, 11, 0),
      type: ActivityType.payment,
      applicationId: 'app-001',
    ),
    ActivityItem(
      title: 'Institution Verified',
      description: 'NIT Rourkela confirmed your enrollment details.',
      timestamp: DateTime(2025, 8, 22, 9, 45),
      type: ActivityType.verification,
      applicationId: 'app-001',
    ),
    ActivityItem(
      title: 'Application Submitted',
      description: 'Post-Matric Scholarship application submitted successfully.',
      timestamp: DateTime(2025, 8, 15, 16, 20),
      type: ActivityType.application,
      applicationId: 'app-001',
    ),
    ActivityItem(
      title: 'Draft Saved',
      description: 'Top Class Education application draft saved.',
      timestamp: DateTime(2025, 9, 10, 20, 0),
      type: ActivityType.application,
      applicationId: 'app-003',
    ),
  ];
}

// ── Supporting types ──────────────────────────────────────────────
enum ActivityType { application, verification, payment, document }

class ActivityItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final String? applicationId;

  const ActivityItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.applicationId,
  });
}
