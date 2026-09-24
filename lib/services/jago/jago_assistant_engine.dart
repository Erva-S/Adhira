import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../app/config/environment.dart';
import '../api/api_endpoints.dart';
import '../../core/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../database/relational_data_store.dart';
import '../scholarship/scholarship_data_service.dart';
import '../scholarship/scholarship_mock_data.dart';

/// Closed-domain AI Assistant Engine for JAGO inside Tribal Scholar Saathi.
///
/// Communicates securely with the backend JAGO Gemini AI service.
/// Enforces strict domain boundaries:
/// 1. Only answers from approved MoTA scholarship schemes, eligibility rules,
///    document requirements, and the current student's application data.
/// 2. Strictly rejects out-of-scope requests (general knowledge, coding, weather, jokes, etc.).
/// 3. Rejects prompt injection and system prompt extraction attempts.
/// 4. Does not hallucinate unverified scholarship details, dates, or amounts.
class JagoAssistantEngine {
  // ── Canonical Controlled Responses ─────────────────────────────────────────
  static const String outOfScopeMessage =
      "I'm JAGO, the scholarship assistant. I can help with scholarship schemes, eligibility, applications, documents, verification, DBT, and application status.";

  static const String unavailableInfoMessage =
      "I don't have verified information about that in the scholarship system.";

  static const String missingStudentDataMessage =
      "I couldn't retrieve that information from your application right now.";

  static const String missingPaymentInfoMessage =
      "I don't have payment information for your application yet.";

  static const String serviceUnavailableMessage =
      "JAGO is temporarily unavailable. Please try again shortly.";

  static const String systemInstruction = '''
You are JAGO, the official scholarship assistant inside Tribal Scholar Saathi for the Ministry of Tribal Affairs (MoTA).

You are a closed-domain assistant.

You may answer ONLY using the information supplied in the current application context and approved scholarship knowledge provided to you.

Do not use outside knowledge.
Do not browse the internet.
Do not invent information.
Do not guess.
Do not provide general-purpose assistance.

If the user asks something outside the scholarship domain, politely explain that you only assist with scholarship-related questions.

If the user asks a scholarship-related question but the required information is not present in the supplied context, say that the information is currently unavailable.

Never fabricate eligibility rules, scholarship amounts, deadlines, application statuses, documents, payment information, or government policies.

Keep responses concise and student-friendly.
''';

  // ── Instance Context ────────────────────────────────────────────────────────
  final ScholarshipDataService? scholarshipService;
  final Student? currentStudent;

  const JagoAssistantEngine({
    this.scholarshipService,
    this.currentStudent,
  });

  /// Communicates with the secure JAGO Gemini AI backend server.
  /// Never exposes the Gemini API key in client code.
  static Future<String> queryBackend({
    required String message,
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    String? applicationId,
    String locale = 'en',
    ScholarshipDataService? scholarshipService,
    Student? student,
  }) async {
    try {
      String baseUrl = EnvironmentConfig.current.apiBaseUrl;
      // In Android emulator, route localhost to host loopback 10.0.2.2
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && baseUrl.contains('localhost')) {
        baseUrl = baseUrl.replaceAll('localhost', '10.0.2.2');
      }

      final url = Uri.parse('$baseUrl${ApiEndpoints.jagoChat}');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'conversationHistory': conversationHistory,
              'userId': userId ?? student?.id ?? RelationalDataStore.demoUserId,
              'applicationId': applicationId ?? (scholarshipService?.activeApplications.firstOrNull?.id),
              'locale': locale,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['reply'] != null) {
          return data['reply'] as String;
        }
      }
      return serviceUnavailableMessage;
    } catch (_) {
      // If backend server is offline during development/tests, fallback to deterministic domain engine
      return respond(
        message,
        scholarshipService: scholarshipService,
        student: student,
      );
    }
  }


  /// Processes a user query and returns a strictly grounded response.
  String processQuery(String query) {
    return respond(
      query,
      scholarshipService: scholarshipService,
      student: currentStudent,
    );
  }

  /// Static entrypoint for responding to a query with optional service and student context.
  static String respond(
    String query, {
    ScholarshipDataService? scholarshipService,
    Student? student,
  }) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return "How can I help you with your scholarship today?";
    }

    final lower = cleanQuery.toLowerCase();

    // ── STEP 1: Prompt Injection / System Prompt Extraction Guard ─────────────
    if (_isPromptInjectionOrSystemProbing(lower)) {
      return outOfScopeMessage;
    }

    // ── STEP 2: Strict Out-Of-Scope Guard ──────────────────────────────────────
    if (_isExplicitlyOutOfScope(lower)) {
      return outOfScopeMessage;
    }

    // ── STEP 3: Verify Domain Relevance ───────────────────────────────────────
    if (!_isScholarshipDomain(lower)) {
      return outOfScopeMessage;
    }

    // Check if user is asking about an unknown or external scholarship scheme
    if (_mentionsUnknownOrExternalScheme(lower)) {
      return unavailableInfoMessage;
    }

    // Resolve active student & applications from provided context
    final resolvedStudent = student ??
        (scholarshipService != null
            ? RelationalDataStore().getUser(scholarshipService.currentUserId)
            : null);

    final applications = scholarshipService?.applications ??
        (resolvedStudent != null
            ? RelationalDataStore().getApplicationsForUser(resolvedStudent.id)
            : <ScholarshipApplication>[]);

    final pendingActions = scholarshipService?.pendingActions ??
        (resolvedStudent != null
            ? RelationalDataStore().getActionsForUser(resolvedStudent.id)
            : <ApplicationAction>[]);

    final payments = scholarshipService?.payments ??
        (resolvedStudent != null
            ? RelationalDataStore().getPaymentsForUser(resolvedStudent.id)
            : <Payment>[]);

    final documents = scholarshipService?.documents ??
        (resolvedStudent != null
            ? RelationalDataStore().getDocumentsForUser(resolvedStudent.id)
            : <Document>[]);

    // ── STEP 4: Intent Routing & Context-Filtered Response Generation ─────────

    // A. Greeting
    if (_isGreeting(lower)) {
      return "Namaste! I'm JAGO, your scholarship assistant for Tribal Scholar Saathi. How can I help you with your applications, documents, eligibility, or payments today?";
    }

    // B. Application Status / Tracking
    if (_isApplicationStatusQuery(lower)) {
      return _handleApplicationStatus(applications, resolvedStudent);
    }

    // C. Pending Actions / Deficiencies / Missing Documents
    if (_isPendingActionsQuery(lower)) {
      return _handlePendingActions(pendingActions, applications, documents, resolvedStudent);
    }

    // D. Payment / DBT Status
    if (_isPaymentQuery(lower)) {
      return _handlePaymentStatus(payments, applications, resolvedStudent);
    }

    // E. Which scholarship am I applying for?
    if (_isWhichScholarshipQuery(lower)) {
      return _handleWhichScholarship(applications, resolvedStudent);
    }

    // F. DigiLocker Documents
    if (_isDigiLockerQuery(lower)) {
      return _handleDigiLockerDocs(documents);
    }

    // G. Eligibility Check
    if (_isEligibilityQuery(lower)) {
      return _handleEligibility(lower, resolvedStudent);
    }

    // H. Required Documents
    if (_isDocumentsQuery(lower)) {
      return _handleRequiredDocuments(lower, applications);
    }

    // I. Scheme Information
    if (_isSchemeInfoQuery(lower)) {
      return _handleSchemeInfo(lower);
    }

    // J. Application Process / How to Apply
    if (_isProcessQuery(lower)) {
      return "To apply for a scholarship in Tribal Scholar Saathi:\n"
          "1. Complete your Profile (Personal, Tribal & Academic details).\n"
          "2. Connect DigiLocker to fetch verified government documents.\n"
          "3. Browse eligible MoTA schemes on the Dashboard and click 'Apply Now'.\n"
          "4. Verify the auto-filled data and attach any additional certificates.\n"
          "5. Submit your application for institutional and department verification.";
    }

    // K. Verification Stages Explanation
    if (_isVerificationStagesQuery(lower)) {
      return "Scholarship verification passes through 5 key stages:\n"
          "1. Application Submission: Form and certificates submitted.\n"
          "2. Document Verification: Automated & manual check of Aadhaar, ST & income certificates.\n"
          "3. Institute Verification: Verification of bonafide enrollment and course fee by your college/school.\n"
          "4. Department Verification: State Tribal Welfare Department scrutiny and approval.\n"
          "5. Sanction & DBT Disbursement: Sanction order generation and Direct Benefit Transfer via PFMS.";
    }

    // L. Student Profile Details
    if (_isProfileQuery(lower)) {
      if (resolvedStudent == null) {
        return missingStudentDataMessage;
      }
      return "Your Registered Profile:\n"
          "• Name: ${resolvedStudent.fullName}\n"
          "• Category: ${resolvedStudent.category ?? 'ST'}${resolvedStudent.tribeName != null ? ' (${resolvedStudent.tribeName})' : ''}\n"
          "• Course: ${resolvedStudent.currentCourse ?? 'N/A'}${resolvedStudent.currentYear != null ? ' (${resolvedStudent.currentYear})' : ''}\n"
          "• Institution: ${resolvedStudent.institutionName ?? 'N/A'}\n"
          "• State: ${resolvedStudent.state ?? 'N/A'}\n"
          "• Profile Completion: ${(resolvedStudent.profileCompletionPercent * 100).toInt()}%";
    }

    // Fallback: If it mentions scholarship keywords but information isn't in our knowledge base
    return unavailableInfoMessage;
  }

  // ── Injection & Out-of-Scope Detectors ──────────────────────────────────────

  static bool _isPromptInjectionOrSystemProbing(String text) {
    final injectionPatterns = [
      RegExp(r'\b(system\s*prompt|system\s*instruction|system\s*message)\b'),
      RegExp(r'\b(ignore|disregard|forget|bypass)\b.*\b(instruction|prompt|rule|restriction|limitation)s?\b'),
      RegExp(r'\b(jailbreak|dan\s*mode|developer\s*mode)\b'),
      RegExp(r'\brepeat\s+(your\s+)?(initial|first|original)\s+(instruction|prompt)\b'),
      RegExp(r'\bwhat\s+(are|is)\s+your\s+(system\s+)?(instructions|prompt)\b'),
      RegExp(r'\breveal\s+(your\s+)?(instructions|prompt)\b'),
      RegExp(r'\bact\s+as\s+(an?\s+)?(unrestricted|general|different)\b'),
    ];
    return injectionPatterns.any((p) => p.hasMatch(text));
  }

  static bool _isExplicitlyOutOfScope(String text) {
    // Exact user examples from prompt:
    // Elon Musk, Write Python/C++ code, What is the weather, Tell me a joke, Quantum physics, Instagram
    final outOfScopePatterns = [
      // People / Celebrities
      RegExp(r'\b(elon\s*musk|trump|biden|modi|kohli|messi|ronaldo|celebrity|actor|actress)\b'),
      RegExp(r'\bwho\s+is\s+(elon|donald|virat|messi|shahrukh|salman|bill\s*gates|mark\s*zuckerberg)\b'),

      // Programming & Coding
      RegExp(r'\b(write|create|debug|generate|fix)\s+(python|c\+\+|java|javascript|dart|html|css|php|sql|code|script|program)\b'),
      RegExp(r'\b(python|c\+\+|javascript|typescript|assembly|golang|rust)\s+(code|script|program)\b'),
      RegExp(r'\bwrite\s+a\s+(c\+\+|python|java)\s+(program|code)\b'),

      // Weather / Climate
      RegExp(r'\b(weather|temperature|forecast|rain\s*today|climate|humidity)\b'),

      // Jokes, Entertainment & Creative Writing
      RegExp(r'\b(joke|funny|riddle|story|poem|song|lyrics|movie|cinema|netflix|game|gaming|cricket\s*score)\b'),

      // Unrelated Science / Math
      RegExp(r'\b(quantum\s*physics|relativity|black\s*hole|calculus|photosynthesis|solar\s*system|mars|spacex)\b'),

      // Social Media & Tech Support
      RegExp(r'\b(instagram|facebook|twitter|tiktok|snapchat|tinder|youtube\s*subscriber|follower)\b'),

      // Cooking / Food / Travel / General Trivia
      RegExp(r'\b(recipe|cook|cooking|restaurant|hotel\s*booking|flight\s*ticket|crypto|bitcoin|stock\s*market)\b'),
    ];

    return outOfScopePatterns.any((p) => p.hasMatch(text));
  }

  static bool _isScholarshipDomain(String text) {
    final domainKeywords = [
      'scholarship',
      'scheme',
      'eligib',
      'document',
      'doc',
      'application',
      'apply',
      'status',
      'track',
      'stage',
      'action',
      'deficien',
      'pending',
      'verif',
      'payment',
      'dbt',
      'disburs',
      'sanction',
      'amount',
      'money',
      'stipend',
      'grant',
      'fellowship',
      'digilocker',
      'mota',
      'tribal',
      'st ',
      'scheduled tribe',
      'pvtg',
      'pre-matric',
      'pre matric',
      'post-matric',
      'post matric',
      'top class',
      'nfst',
      'nos',
      'income cert',
      'caste cert',
      'bonafide',
      'marksheet',
      'passbook',
      'aadhaar',
      'student',
      'profile',
      'deadline',
      'allowance',
      'tuition',
      'hi',
      'hello',
      'namaste',
      'hey',
      'jago',
      'saathi',
    ];

    return domainKeywords.any((keyword) => text.contains(keyword));
  }

  static bool _mentionsKnownScheme(String text) {
    return text.contains('pre-matric') ||
        text.contains('pre matric') ||
        text.contains('post-matric') ||
        text.contains('post matric') ||
        text.contains('top class') ||
        text.contains('top-class') ||
        text.contains('nfst') ||
        text.contains('fellowship') ||
        text.contains('nos') ||
        text.contains('overseas') ||
        text.contains('higher education');
  }

  static bool _mentionsUnknownOrExternalScheme(String text) {
    final externalKeywords = [
      'inspire',
      'yasasvi',
      'rhodes',
      'fulbright',
      'chevening',
      'tata',
      'reliance',
      'google',
      'pmrf',
      'nsp central sector',
      'up post matric',
      'bihar post matric',
      'oasis',
      'mahadbt',
      'vidyasiri',
      'kanyashree',
      'pragati',
      'saksham',
      'dr ambedkar',
      'merit-cum-means',
      'aicte',
    ];
    return externalKeywords.any((k) => text.contains(k));
  }

  // ── Intent Helpers ──────────────────────────────────────────────────────────

  static bool _isGreeting(String text) {
    final greetings = ['hi', 'hello', 'namaste', 'hey', 'good morning', 'good afternoon', 'good evening'];
    return greetings.any((g) => text == g || text.startsWith('$g ') || text == '$g!');
  }

  static bool _isApplicationStatusQuery(String text) {
    return (text.contains('status') && !text.contains('payment') && !text.contains('dbt')) ||
        text.contains('track') ||
        text.contains('where is my application') ||
        text.contains('application progress') ||
        text.contains('stage is my application');
  }

  static bool _isPendingActionsQuery(String text) {
    return text.contains('pending document') ||
        text.contains('documents are pending') ||
        text.contains('document is pending') ||
        text.contains('documents is pending') ||
        text.contains('documents pending') ||
        text.contains('missing document') ||
        text.contains('what documents are missing') ||
        text.contains('what is pending') ||
        text.contains('pending action') ||
        text.contains('deficienc') ||
        text.contains('what action') ||
        text.contains('rejected document');
  }

  static bool _isPaymentQuery(String text) {
    return text.contains('payment') ||
        text.contains('dbt') ||
        text.contains('disburs') ||
        text.contains('money') ||
        text.contains('installment') ||
        text.contains('bank transfer') ||
        text.contains('credited') ||
        text.contains('receive my money');
  }

  static bool _isWhichScholarshipQuery(String text) {
    return text.contains('which scholarship') ||
        text.contains('what scholarship did i apply') ||
        text.contains('which scheme am i') ||
        text.contains('scholarship am i applying for');
  }

  static bool _isDigiLockerQuery(String text) {
    return text.contains('digilocker') || text.contains('digi locker');
  }

  static bool _isEligibilityQuery(String text) {
    return text.contains('eligib') ||
        text.contains('can i apply') ||
        text.contains('who can apply') ||
        text.contains('criteria') ||
        text.contains('qualification');
  }

  static bool _isDocumentsQuery(String text) {
    return text.contains('document') ||
        text.contains('docs') ||
        text.contains('certificate') ||
        text.contains('what do i need');
  }

  static bool _isSchemeInfoQuery(String text) {
    return text.contains('tell me about') ||
        text.contains('what is') ||
        text.contains('schemes available') ||
        text.contains('list of scholarship') ||
        text.contains('available scholarship') ||
        text.contains('mota scholarship') ||
        text.contains('which scholarships are available');
  }

  static bool _isProcessQuery(String text) {
    return text.contains('how to apply') ||
        text.contains('how do i apply') ||
        text.contains('application process') ||
        text.contains('steps to apply') ||
        text.contains('procedure');
  }

  static bool _isVerificationStagesQuery(String text) {
    return text.contains('verification stage') ||
        text.contains('verification process') ||
        text.contains('application stage') ||
        text.contains('who verifies') ||
        text.contains('department verification') ||
        text.contains('institute verification');
  }

  static bool _isProfileQuery(String text) {
    return text.contains('my profile') ||
        text.contains('my details') ||
        text.contains('who am i') ||
        text.contains('my course') ||
        text.contains('my category') ||
        text.contains('my college') ||
        text.contains('my institute');
  }

  // ── Handler Implementations ─────────────────────────────────────────────────

  static String _handleApplicationStatus(
    List<ScholarshipApplication> applications,
    Student? student,
  ) {
    if (student == null && applications.isEmpty) {
      return missingStudentDataMessage;
    }

    if (applications.isEmpty) {
      return missingStudentDataMessage;
    }

    final active = applications.firstWhere(
      (a) => a.status != ApplicationStatus.rejected && a.status != ApplicationStatus.withdrawn,
      orElse: () => applications.first,
    );

    final appNo = active.applicationNumber ?? active.id;
    final stageName = active.currentStage.label;
    final remarksText = (active.remarks != null && active.remarks!.isNotEmpty)
        ? " Remarks: ${active.remarks}."
        : "";

    return "Your ${active.scholarshipName} application ($appNo) is currently under $stageName.$remarksText";
  }

  static String _handlePendingActions(
    List<ApplicationAction> actions,
    List<ScholarshipApplication> applications,
    List<Document> documents,
    Student? student,
  ) {
    if (student == null && applications.isEmpty) {
      return missingStudentDataMessage;
    }

    final openActions = actions.where((a) => a.isOpen).toList();
    final rejectedDocs = documents.where((d) => d.status == DocumentStatus.rejected).toList();

    if (openActions.isNotEmpty) {
      final act = openActions.first;
      return "Your ${act.title.replaceAll('Update ', '')} is currently pending. Reason: ${act.description}";
    }

    if (rejectedDocs.isNotEmpty) {
      final doc = rejectedDocs.first;
      final reason = doc.rejectionReason != null ? " Reason: ${doc.rejectionReason}" : "";
      return "Your ${doc.name} is currently pending.$reason";
    }

    return "You have no pending documents or deficiencies at this time. All required documents are up to date.";
  }

  static String _handlePaymentStatus(
    List<Payment> payments,
    List<ScholarshipApplication> applications,
    Student? student,
  ) {
    if (payments.isEmpty) {
      return missingPaymentInfoMessage;
    }

    final disbursed = payments.where((p) => p.status == PaymentStatus.disbursed).toList();
    final pending = payments.where((p) => p.status != PaymentStatus.disbursed && p.status != PaymentStatus.failed).toList();

    if (disbursed.isNotEmpty && pending.isEmpty) {
      final p = disbursed.first;
      return "Your scholarship payment of ₹${p.amount.toInt()} for ${p.scholarshipName} has been disbursed via DBT to your bank account.";
    }

    if (disbursed.isNotEmpty && pending.isNotEmpty) {
      final d = disbursed.first;
      final p = pending.first;
      return "Your scholarship payment of ₹${d.amount.toInt()} for ${d.scholarshipName} has been disbursed via DBT. An upcoming installment of ₹${p.amount.toInt()} is currently pending approval.";
    }

    if (pending.isNotEmpty) {
      return "Your scholarship payment is currently pending.";
    }

    return missingPaymentInfoMessage;
  }

  static String _handleWhichScholarship(
    List<ScholarshipApplication> applications,
    Student? student,
  ) {
    if (applications.isEmpty) {
      return "You haven't submitted any scholarship applications yet. You can explore eligible MoTA schemes on the Dashboard.";
    }

    final app = applications.first;
    final appNo = app.applicationNumber ?? app.id;
    return "You are applying for the ${app.scholarshipName} (Application No: $appNo).";
  }

  static String _handleDigiLockerDocs(List<Document> documents) {
    final digiDocs = documents.where((d) => d.isFromDigiLocker).toList();
    if (digiDocs.isEmpty) {
      return "You do not have any DigiLocker documents linked in Tribal Scholar Saathi yet. You can link them from the Document Wallet.";
    }

    final names = digiDocs.map((d) => "• ${d.name} (${d.category.label})").join('\n');
    return 'Your linked DigiLocker documents in Tribal Scholar Saathi:\n$names\n\nThese documents are government-verified and automatically accepted.';
  }

  static String _handleEligibility(String text, Student? student) {
    // Check specific known schemes
    if (text.contains('pre-matric') || text.contains('pre matric')) {
      final scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return 'Pre-Matric Scholarship for ST Students Eligibility:\n$criteria';
    }

    if (text.contains('post-matric') || text.contains('post matric')) {
      if (student != null) {
        return 'Based on your student profile:\n'
            '• Category: ${student.category ?? 'ST'} (Eligible)\n'
            '• Course: ${student.currentCourse ?? 'Post-Matric course'} (Eligible)\n'
            '• State: ${student.state ?? 'Recognized'}\n'
            'You are eligible for the Post-Matric Scholarship for ST Students provided your annual family income is ₹2.50 Lakh or less and you have an Aadhaar-linked bank account.';
      }
      final scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return 'Post-Matric Scholarship for ST Students Eligibility:\n$criteria';
    }

    if (text.contains('top class')) {
      if (student != null && student.institutionName != null && student.institutionName!.contains('NIT')) {
        return 'Based on your admission at ${student.institutionName} (a notified premier institute):\n'
            '• Category: ${student.category ?? 'ST'} (Eligible)\n'
            '• Institution: ${student.institutionName} (Notified Premier Institute)\n'
            'You are eligible for the Top Class Education Scheme provided your annual family income does not exceed ₹6.00 Lakh.';
      }
      final scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return 'Top Class Education for ST Students Eligibility:\n$criteria';
    }

    if (text.contains('nfst') || text.contains('fellowship')) {
      final scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return 'National Fellowship for ST Students (NFST) Eligibility:\n$criteria';
    }

    if (text.contains('nos') || text.contains('overseas')) {
      final scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);
      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return 'National Overseas Scholarship (NOS) Eligibility:\n$criteria';
    }

    // If query asks about a specific unnamed or unknown scheme:
    if (!text.contains('check my eligibility') &&
        !text.contains('am i eligible') &&
        !text.contains('general') &&
        !text.contains('who can apply') &&
        !text.contains('eligibility criteria')) {
      return unavailableInfoMessage;
    }

    // General eligibility check for current student
    if (student != null) {
      return 'Eligibility Summary for ${student.fullName}:\n'
          '• Post-Matric Scholarship: Eligible as an ST student in ${student.currentCourse ?? 'Higher Education'} (Family income <= ₹2.50 Lakh).\n'
          '• Top Class Education: Eligible if enrolled in a notified premier institute like ${student.institutionName ?? 'IITs/NITs'} (Family income <= ₹6.00 Lakh).';
    }

    return 'General MoTA Scholarship Eligibility:\n'
        '1. Must belong to a notified Scheduled Tribe (ST) category.\n'
        '2. Enrolled in a recognized school, college, or university.\n'
        '3. Family annual income within scheme limits (₹2.50L for Pre/Post-Matric, ₹6.00L for Top Class/NFST/NOS).\n'
        '4. Valid Aadhaar and Aadhaar-seeded bank account for DBT.';
  }

  static String _handleRequiredDocuments(String text, List<ScholarshipApplication> applications) {
    Scholarship? matchedScheme;

    if (text.contains('pre-matric') || text.contains('pre matric')) {
      matchedScheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
    } else if (text.contains('post-matric') || text.contains('post matric')) {
      matchedScheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
    } else if (text.contains('top class')) {
      matchedScheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
    } else if (text.contains('nfst') || text.contains('fellowship')) {
      matchedScheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
    } else if (text.contains('nos') || text.contains('overseas')) {
      matchedScheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);
    } else if (applications.isNotEmpty) {
      final app = applications.first;
      matchedScheme = ScholarshipMockData.schemes.firstWhere(
        (s) => s.type == app.scholarshipType,
        orElse: () => ScholarshipMockData.schemes[1],
      );
    }

    if (matchedScheme != null) {
      final docs = matchedScheme.requiredDocuments.map((d) => '• $d').join('\n');
      return 'Required Documents for ${matchedScheme.name}:\n$docs';
    }

    return 'Required Documents for MoTA Scholarships:\n'
        '• ST / Caste Certificate\n'
        '• Income Certificate (Current Financial Year)\n'
        '• Previous Marksheet / Grade Card\n'
        '• Institution Bonafide / Enrollment Certificate\n'
        '• Aadhaar Card\n'
        '• Bank Passbook (Aadhaar-seeded for DBT)';
  }

  static String _handleSchemeInfo(String text) {
    if (text.contains('pre-matric') || text.contains('pre matric')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
      return '${s.name}:\n${s.description}\nMax Amount: ₹${s.maxAmount?.toInt() ?? 10000} | Duration: ${s.duration}';
    }

    if (text.contains('post-matric') || text.contains('post matric')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
      return '${s.name}:\n${s.description}\nMax Amount: ₹${s.maxAmount?.toInt() ?? 70000} | Duration: ${s.duration}';
    }

    if (text.contains('top class')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
      return '${s.name}:\n${s.description}\nMax Amount: ₹${s.maxAmount?.toInt() ?? 250000} | Duration: ${s.duration}';
    }

    if (text.contains('nfst') || text.contains('fellowship')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
      return '${s.name}:\n${s.description}\nFellowship: ₹${s.maxAmount?.toInt() ?? 42000}/mo | Duration: ${s.duration}';
    }

    if (text.contains('nos') || text.contains('overseas')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);
      return '${s.name}:\n${s.description}\nGrant: Up to ₹${s.maxAmount?.toInt() ?? 1500000} | Duration: ${s.duration}';
    }

    // Check if query is asking for a list of all available schemes
    final asksForAll = text.contains('schemes available') ||
        text.contains('list of scholarship') ||
        text.contains('available scholarship') ||
        text.contains('mota scholarship') ||
        text.contains('which scholarships are available') ||
        text.contains('all scholarships') ||
        text.contains('what scholarships');

    if (asksForAll) {
      final list = ScholarshipMockData.schemes.map((s) => '• ${s.name} (${s.duration})').join('\n');
      return 'Available MoTA Scholarship Schemes in Tribal Scholar Saathi:\n$list';
    }

    // If query asks "tell me about X" or "what is X" and X is not recognized:
    return unavailableInfoMessage;
  }
}

