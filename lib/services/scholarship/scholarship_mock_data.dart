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
          'Centrally Sponsored Scheme by MoTA for ST students in Classes IX & X to minimize dropouts and support progression to post-matric education.',
      detailedDescription:
          'Pre-Matric Scholarship is a Centrally Sponsored Scheme implemented by the Ministry of Tribal Affairs (75:25 Centre-State ratio, 90:10 for North East/Hilly states). '
          'It supports ST students in Classes IX and X studying in government schools or recognized schools. '
          'Disbursement is conducted directly to student bank accounts linked with Aadhaar via DBT. '
          'Income certificate is required once at Class IX admission and remains valid for Class X.',
      maxAmount: 6250,
      duration: '10 Months per Academic Year',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category (Domicile State)',
        'Must be studying in Class IX or Class X in a Government or recognized school',
        'Family annual income from all sources must not exceed ₹2.50 Lakh per annum',
        'Must hold an active bank account linked with Aadhaar and mobile number',
        'Must not be availing any other government scholarship',
        'Scholarship is available for one year only per class (repeating students not eligible for same class)',
      ],
      requiredDocuments: [
        'Aadhaar Number / Card',
        'Domicile Certificate',
        'ST / Caste Certificate issued by competent authority of State',
        'Family Income Certificate (issued by competent authority, self-affidavits not accepted)',
        'Disability Certificate (if claiming Divyangjan allowance)',
        'Passport Size Photograph',
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
          'Centrally Sponsored flagship scheme for ST students pursuing Class XI to Post Graduation courses in India.',
      detailedDescription:
          'Post-Matric Scholarship for ST Students is applicable from 01-04-2022. It covers compulsory non-refundable fees and monthly stipends across 4 course groups. '
          'In private sector institutes, central support has a ceiling of ₹2.50 Lakh/year for Engineering, ₹6.00 Lakh/year for MBBS/MS/MD, and ₹1.00 Lakh/year for other courses. '
          'Stipends range from ₹230 to ₹1,200/month for up to 10 months. '
          'Candidates who complete a course in one stream cannot take a course in a different stream at the same level.',
      maxAmount: 130000,
      duration: 'Duration of the Course',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) of the Domicile State',
        'Must have passed Matriculation (Class X) or Higher Secondary or higher qualifying examination',
        'Family annual income from all sources must not exceed ₹2.50 Lakh per annum',
        'Income certificate taken once at admission is valid for entire course duration',
        'Active bank account linked with Aadhaar and mobile number for DBT',
        'Must not be holding another scholarship/stipend concurrently',
        'Enrolled in recognized Govt / UGC / NAAC A / NBA / NCVT / AICTE accredited institutions',
      ],
      requiredDocuments: [
        'Aadhaar Number / Card',
        'Domicile Certificate',
        'ST / Caste Certificate issued by competent State/UT authority',
        'Family Income Certificate (self-declaration affidavits strictly unacceptable)',
        'Certificates, diploma, degree marksheets of all examinations passed',
        'Last qualified examination marksheet / percentage',
        'Disability Certificate (if Divyangjan allowance claimed)',
        'Passport Size Photograph',
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
          '100% Central Sector Scheme for ST students admitted on merit to 252 notified premier institutes (IITs, NITs, IIMs, AIIMS, NLUs).',
      detailedDescription:
          'Top Class Education Scheme provides 100% funding for Graduate and Post-Graduate ST students admitted to 252 notified premier institutions. '
          'Covers full tuition and non-refundable fees in Govt institutes (₹2.50 Lakh/year cap in private institutes), ₹5,000/year books/stationery, '
          '₹3,000/month living stipend, and ₹45,000 one-time computer/accessories assistance. '
          'There is no Institute-wise, State-wise, or stream-wise ceiling of number of slots.',
      maxAmount: 500000,
      duration: 'Duration of the Course',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must have secured admission on merit in one of the 252 notified premier institutes',
        'Total family income from all sources must not exceed ₹6.00 Lakh per annum (includes spousal income if married)',
        'Students admitted under Management Quota in private institutes are not eligible',
        'Students availing this scheme cannot claim benefit of another Central/State scholarship',
        'Income certificate for preceding financial year required once at admission',
      ],
      requiredDocuments: [
        'ST / PVTG Certificate signed and stamped by competent authority',
        'Family Income Certificate (or Form-16 for salaried employees) for preceding financial year',
        'Fee Receipt',
        'Scanned copy of Bank Passbook (Aadhaar seeded, matching student name)',
        'Marksheet / Certificate of qualifying exam (12th standard for UG, Graduation for PG)',
        'Bonafide Certificate issued by the Institute',
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
          'Central Sector Scheme providing 750 fresh fellowships annually to ST scholars pursuing regular, full-time M.Phil and Ph.D in India.',
      detailedDescription:
          'NFST provides 750 fresh fellowship slots annually (38 Divyangjan, 25 PVTG, 225 Female, 462 ST Others). '
          'Crucially, there is NO INCOME CRITERIA for eligibility. '
          'Fellowship values: M.Phil ₹31,000/month + ₹10,000 - ₹12,000 contingency; Ph.D ₹31,000/month (first 2 yrs) & ₹35,000/month (remaining 3 yrs) + ₹20,500 - ₹25,000 contingency. '
          'HRA at UGC rates (8%, 16%, or 24%) and ₹2,000/month escort allowance for Divyangjan. Disbursed quarterly via PFMS-DBT.',
      maxAmount: 420000,
      duration: '2 Years for M.Phil, 5 Years for Ph.D',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Must have passed Post-Graduation / Master Degree with minimum 55% marks',
        'Enrolled in regular & full-time M.Phil or Ph.D in UGC 2(f)/12(B), Deemed, State/Central Grant, or INI institutes',
        'NO INCOME CRITERIA: There is no income ceiling for eligibility',
        'Age Limit: Maximum 36 years as on 1st July of the relevant selection year',
        'Priority given to scholars with admission offers in IITs, AIIMS, IIMs, IISERs',
      ],
      requiredDocuments: [
        'Latest coloured passport size photograph',
        'ST / PVTG Certificate issued by competent authority',
        '10th / Matriculation certificate in support of date of birth',
        'Divyangjan Certificate certifying minimum 40% disability (if applicable)',
        'Post-Graduation mark sheet (minimum 55% marks or CGPA conversion formula)',
        'Admission / Joining certificate of M.Phil / Ph.D from concerned University',
        'Offer of admission from IITs / AIIMS / IIMs / IISERs (if applicable)',
        'Aadhaar Card and DigiLocker registration (mandatory)',
      ],
      applicationDeadline: DateTime(2026, 3, 15),
      isOpen: true,
      portalUrl: 'https://fellowship.tribal.gov.in',
    ),
    Scholarship(
      id: 'sch-nos',
      type: ScholarshipType.nos,
      name: 'National Overseas Scholarship for ST Students',
      description:
          'Financial assistance for meritorious ST students pursuing Masters and Ph.D courses in Top 1,000 QS world-ranked foreign universities.',
      detailedDescription:
          'National Overseas Scholarship (NOS) supports ST candidates pursuing post-graduate courses (Masters and Ph.D) abroad. '
          'IMPORTANT 2026-27 AMENDMENT: Post-Doctoral Research is omitted from 2026-27 onwards. '
          'First priority is given to candidates with an unconditional offer of admission from Top 1,000 QS world-ranked foreign universities/institutes. '
          'Ties decided by marks in the qualifying examination. Vacant slots filled via expert interview committee with preference for GRE/GMAT/TOEFL scores. '
          'Candidate verification conducted through respective State/UT.',
      maxAmount: 2000000,
      duration: 'Duration of Course (Masters / Ph.D)',
      eligibilityCriteria: [
        'Must belong to a notified Scheduled Tribe (ST) category',
        'Pursuing Masters or Ph.D abroad (Post-Doctoral Research omitted from 2026-27 onwards)',
        'First priority: Offer of admission from Top 1,000 QS world-ranked foreign universities/institutes',
        'Family annual income must not exceed ₹6.00 Lakh per annum',
        'Must hold a valid Indian Passport',
        'Tie-breaking based on marks/grades secured in the qualifying examination',
        'Verification of selected candidates conducted through respective State/UT',
      ],
      requiredDocuments: [
        'ST / Tribe Certificate issued by competent authority',
        'Family Income Certificate',
        'Unconditional Admission Offer from Top 1,000 QS-ranked foreign university',
        'Valid Passport',
        'Academic marksheets and degree certificates of qualifying examination',
        'GRE / GMAT / TOEFL / IELTS scorecard (gives preference for vacant slot interviews)',
        'Aadhaar Card',
        'Bank account details',
        'Passport Photo',
      ],
      applicationDeadline: DateTime(2026, 4, 30),
      isOpen: true,
      portalUrl: 'https://overseas.tribal.gov.in',
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
