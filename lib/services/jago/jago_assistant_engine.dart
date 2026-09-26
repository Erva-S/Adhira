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
import '../scholarship/scholarship_eligibility_service.dart';
import 'jago_mlkit_service.dart';

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
      'JAGO is temporarily unavailable. Please try again shortly.';

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

  /// Returns a dynamic language instruction communicating the user's selected JAGO language,
  /// mixed-language input comprehension, official terminology preservation, and output domain boundaries.
  static String _languageInstruction(String languageCode) {
    const languageNames = {
      'en': 'English',
      'hi': 'Hindi',
      'gu': 'Gujarati',
      'mr': 'Marathi',
      'bn': 'Bengali',
      'ta': 'Tamil',
      'te': 'Telugu',
      'kn': 'Kannada',
      'ml': 'Malayalam',
    };
    final langName = languageNames[languageCode] ?? 'English';
    return '''
You are JAGO, the scholarship assistant inside Adhira.
Respond directly in the user's selected JAGO language: $langName ($languageCode).
Understand questions even when the user writes in another language, including mixed-language input such as Hinglish or Gujarati-English.
Generate the final answer directly in $langName.
Do not unnecessarily mix languages.
Preserve official scholarship names, scheme names, government terminology, abbreviations, document names, and technical terms accurately.
Specifically preserve terms such as: NSP, SFMP, NOS, NFST, DBT, DigiLocker, APAAR, AISHE, UDISE+, UIDAI, UGC, NTA, Aadhaar, Pre-Matric, Post-Matric, Top Class, National Overseas Scholarship.
If an official term is normally written in English, it is acceptable to retain the official English term while explaining it in $langName.
Keep answers clear and natural for students.
Do not translate official scheme names into potentially incorrect names.
Remain strictly within the scholarship/education-assistance domain.
''';
  }

  /// Generates a context-aware initial message when JAGO is opened from a specific screen.
  static String? generateContextMessage({
    required String sourceScreen,
    ScholarshipApplication? application,
    Scholarship? scholarship,
    String languageCode = 'en',
  }) {
    final buffer = StringBuffer();

    switch (sourceScreen) {
      case 'applicationTracking':
      case 'applicationDetail':
        if (application != null) {
          final appNo = application.applicationNumber ?? application.id;
          final status = application.status.label;
          final stage = application.currentStage.label;
          buffer.writeln('I can see you were viewing your ${application.scholarshipName} application ($appNo).');
          buffer.writeln('Current status: $status (Stage: $stage).');
          if (application.remarks != null && application.remarks!.isNotEmpty) {
            buffer.writeln('Remarks: ${application.remarks}.');
          }
          buffer.writeln('\nAsk me about its status, pending actions, required documents, or the application timeline.');
        } else {
          buffer.writeln('I can help you with application tracking. Ask me about your application status, pending actions, or documents.');
        }
        break;
      case 'eligibility':
        if (scholarship != null) {
          buffer.writeln('I can help you check eligibility for ${scholarship.name}.');
        } else {
          buffer.writeln('I can help you check your eligibility for scholarship schemes. Ask me about specific criteria or what you might be missing.');
        }
        break;
      case 'documents':
        buffer.writeln('I can help you with your documents. Ask about required documents, verification status, or DigiLocker integration.');
        break;
      case 'payments':
        buffer.writeln('I can help you with your payment and DBT status. Ask about disbursements, pending installments, or payment timeline.');
        break;
      default:
        return null;
    }

    return buffer.toString().trim();
  }

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
    String? screenContext,
  }) async {
    final mlKitService = JagoMlKitService();
    String? detectedLanguage;
    try {
      detectedLanguage = await mlKitService.identifyLanguage(message);
    } catch (_) {}

    try {
      String baseUrl = EnvironmentConfig.current.apiBaseUrl;
      // On Android, support physical phones (localhost with adb reverse) and emulators (10.0.2.2)
      final List<Uri> candidateUrls = [
        Uri.parse('$baseUrl${ApiEndpoints.jagoChat}'),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && baseUrl.contains('localhost'))
          Uri.parse('${baseUrl.replaceAll('localhost', '10.0.2.2')}${ApiEndpoints.jagoChat}'),
      ];

      // Build the dynamic language instruction for the system prompt
      final languageInstruction = _languageInstruction(locale);

      for (final targetUrl in candidateUrls) {
        try {
          final response = await http
              .post(
                targetUrl,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'message': message,
                  'conversationHistory': conversationHistory,
                  'userId': userId ?? student?.id ?? RelationalDataStore.demoUserId,
                  'applicationId': applicationId ?? (scholarshipService?.activeApplications.firstOrNull?.id),
                  'locale': locale,
                  'detectedLanguage': detectedLanguage,
                  if (languageInstruction.isNotEmpty) 'languageInstruction': languageInstruction,
                  if (screenContext != null) 'screenContext': screenContext,
                }),
              )
              .timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            if (data['success'] == true && data['reply'] != null) {
              String reply = data['reply'] as String;
              // If target language is non-English and response was returned in English (fallback needed)
              if (locale != 'en') {
                final responseScript = JagoMlKitService.detectScriptLanguage(reply);
                if (responseScript == 'en') {
                  final translated = await mlKitService.translateFallback(
                    text: reply,
                    sourceLangCode: 'en',
                    targetLangCode: locale,
                  );
                  if (translated != null && translated.trim().isNotEmpty) {
                    reply = translated.trim();
                  }
                }
              }
              return reply;
            }
          }
        } catch (_) {
          continue;
        }
      }

      // If backend was unreachable or returned non-200, fallback to deterministic knowledge engine
      final fallbackResponse = respond(
        message,
        conversationHistory: conversationHistory,
        scholarshipService: scholarshipService,
        student: student,
      );

      if (locale != 'en') {
        final translated = await mlKitService.translateFallback(
          text: fallbackResponse,
          sourceLangCode: 'en',
          targetLangCode: locale,
        );
        if (translated != null && translated.trim().isNotEmpty) {
          return translated.trim();
        }
      }

      return fallbackResponse;
    } catch (_) {
      final fallbackResponse = respond(
        message,
        conversationHistory: conversationHistory,
        scholarshipService: scholarshipService,
        student: student,
      );

      if (locale != 'en') {
        try {
          final translated = await mlKitService.translateFallback(
            text: fallbackResponse,
            sourceLangCode: 'en',
            targetLangCode: locale,
          );
          if (translated != null && translated.trim().isNotEmpty) {
            return translated.trim();
          }
        } catch (_) {}
      }

      return fallbackResponse;
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

  /// Extracts the most recently discussed scholarship scheme from conversation history.
  static String? _extractSchemeFromHistory(List<Map<String, String>> history) {
    if (history.isEmpty) return null;
    for (int i = history.length - 1; i >= 0; i--) {
      final msg = history[i];
      final text = (msg['text'] ?? '').toLowerCase();
      if (text.contains('top class') || text.contains('top-class')) return 'top class';
      if (text.contains('nfst') || text.contains('fellowship')) return 'nfst';
      if (text.contains('nos') || text.contains('overseas')) return 'nos';
      if (text.contains('pre-matric') || text.contains('pre matric')) return 'pre-matric';
      if (text.contains('post-matric') || text.contains('post matric')) return 'post-matric';
    }
    return null;
  }

  /// Static entrypoint for responding to a query with optional service, student, and conversation history context.
  static String respond(
    String query, {
    List<Map<String, String>> conversationHistory = const [],
    ScholarshipDataService? scholarshipService,
    Student? student,
  }) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return 'How can I help you with your scholarship today?';
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

    // Contextual Scheme Resolution: if query is a follow-up without an explicit scheme,
    // infer the scheme from previous conversation turns.
    final historicalScheme = _extractSchemeFromHistory(conversationHistory);
    final effectiveLower = (historicalScheme != null && !_mentionsKnownScheme(lower))
        ? '$lower $historicalScheme'
        : lower;

    // ── STEP 3: Verify Domain Relevance ───────────────────────────────────────
    if (!_isScholarshipDomain(lower) && !_isScholarshipDomain(effectiveLower)) {
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
    if (_isEligibilityQuery(effectiveLower)) {
      return _handleEligibility(effectiveLower, resolvedStudent);
    }

    // H. Required Documents
    if (_isDocumentsQuery(effectiveLower)) {
      return _handleRequiredDocuments(effectiveLower, applications);
    }

    // I. Scheme Information
    if (_isSchemeInfoQuery(effectiveLower)) {
      return _handleSchemeInfo(effectiveLower);
    }

    // J. Application Process / How to Apply
    if (_isProcessQuery(lower)) {
      return 'To apply for a scholarship in Tribal Scholar Saathi:\n'
          '1. Complete your Profile (Personal, Tribal & Academic details).\n'
          '2. Connect DigiLocker to fetch verified government documents.\n'
          "3. Browse eligible MoTA schemes on the Dashboard and click 'Apply Now'.\n"
          '4. Verify the auto-filled data and attach any additional certificates.\n'
          '5. Submit your application for institutional and department verification.';
    }

    // K. Verification Stages Explanation
    if (_isVerificationStagesQuery(lower)) {
      return 'Scholarship verification passes through 5 key stages:\n'
          '1. Application Submission: Form and certificates submitted.\n'
          '2. Document Verification: Automated & manual check of Aadhaar, ST & income certificates.\n'
          '3. Institute Verification: Verification of bonafide enrollment and course fee by your college/school.\n'
          '4. Department Verification: State Tribal Welfare Department scrutiny and approval.\n'
          '5. Sanction & DBT Disbursement: Sanction order generation and Direct Benefit Transfer via PFMS.';
    }

    // L. Student Profile Details
    if (_isProfileQuery(lower)) {
      if (resolvedStudent == null) {
        return missingStudentDataMessage;
      }
      return 'Your Registered Profile:\n'
          '• Name: ${resolvedStudent.fullName}\n'
          "• Category: ${resolvedStudent.category ?? 'ST'}${resolvedStudent.tribeName != null ? ' (${resolvedStudent.tribeName})' : ''}\n"
          "• Course: ${resolvedStudent.currentCourse ?? 'N/A'}${resolvedStudent.currentYear != null ? ' (${resolvedStudent.currentYear})' : ''}\n"
          "• Institution: ${resolvedStudent.institutionName ?? 'N/A'}\n"
          "• State: ${resolvedStudent.state ?? 'N/A'}\n"
          '• Profile Completion: ${(resolvedStudent.profileCompletionPercent * 100).toInt()}%';
    }

    // Fallback: If it is within scholarship domain, provide helpful guidance instead of hard error
    return 'Generally, scholarship eligibility and benefits depend on factors such as academic level, annual family income, category, and institution. For specific official rules, please refer to the latest official MoTA scheme guidelines.';
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
      // Multilingual keywords for supported regional languages
      // Hindi / Marathi
      'छात्रवृत्ति', 'शिष्यवृत्ती', 'पात्रता', 'स्थिति', 'दस्तावेज', 'आवेदन', 'पैसे', 'बैंक',
      // Gujarati
      'શિષ્યવૃત્તિ', 'પાત્રતા', 'સ્થિતિ', 'દસ્તાવેજ', 'અરજી', 'પૈસા',
      // Bengali
      'বৃত্তি', 'স্কলারশিপ', 'যোগ্যতা', 'নথি', 'আবেদন',
      // Tamil
      'உதவித்தொகை', 'தகுதி', 'நிலை', 'ஆவணங்கள்', 'விண்ணப்பம்',
      // Telugu
      'స్కాలర్‌షిప్', 'ఉపకార వేతనం', 'అర్హత', 'స్థితి', 'పత్రాలు', 'దరఖాస్తు',
      // Kannada
      'ವಿದ್ಯಾರ್ಥಿವೇತನ', 'ಅರ್ಹತೆ', 'ಸ್ಥಿತಿ', 'ದಾಖಲೆಗಳು', 'ಅರ್ಜಿ',
      // Malayalam
      'സ്കോളർഷിപ്പ്', 'യോഗ്യത', 'അവസ്ഥ', 'രേഖകൾ', 'അപേക്ഷ',
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
    final greetings = [
      'hi', 'hello', 'namaste', 'hey', 'good morning', 'good afternoon', 'good evening',
      'नमस्ते', 'નમસ્તે', 'নমস্কার', 'வணக்கம்', 'నమస్కారం', 'ನಮಸ್ಕಾರ', 'നമസ്കാരം'
    ];
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
    if (text.contains('what is dbt') || text.contains('what does dbt mean') || text.trim() == 'dbt' || text.contains('explain dbt')) {
      return false; // Route to scheme/concept handler
    }
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
        text.contains('qualification') ||
        text.contains('what am i missing') ||
        text.contains('what is missing') ||
        (text.contains('why') && (text.contains('not') || text.contains('ineligible')));
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
        text.contains('detail') ||
        text.contains('explain') ||
        text.contains('overview') ||
        text.contains('information') ||
        text.contains('about ') ||
        text.contains('schemes available') ||
        text.contains('list of scholarship') ||
        text.contains('available scholarship') ||
        text.contains('mota scholarship') ||
        text.contains('which scholarships are available') ||
        text.contains('pre-matric') ||
        text.contains('pre matric') ||
        text.contains('post-matric') ||
        text.contains('post matric') ||
        text.contains('top class') ||
        text.contains('nfst') ||
        text.contains('nos') ||
        text.contains('dbt');
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
        ? ' Remarks: ${active.remarks}.'
        : '';

    return 'Your ${active.scholarshipName} application ($appNo) is currently under $stageName.$remarksText';
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
      final reason = doc.rejectionReason != null ? ' Reason: ${doc.rejectionReason}' : '';
      return 'Your ${doc.name} is currently pending.$reason';
    }

    return 'You have no pending documents or deficiencies at this time. All required documents are up to date.';
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
      return 'Your scholarship payment of ₹${p.amount.toInt()} for ${p.scholarshipName} has been disbursed via DBT to your bank account.';
    }

    if (disbursed.isNotEmpty && pending.isNotEmpty) {
      final d = disbursed.first;
      final p = pending.first;
      return 'Your scholarship payment of ₹${d.amount.toInt()} for ${d.scholarshipName} has been disbursed via DBT. An upcoming installment of ₹${p.amount.toInt()} is currently pending approval.';
    }

    if (pending.isNotEmpty) {
      return 'Your scholarship payment is currently pending.';
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
    return 'You are applying for the ${app.scholarshipName} (Application No: $appNo).';
  }

  static String _handleDigiLockerDocs(List<Document> documents) {
    final digiDocs = documents.where((d) => d.isFromDigiLocker).toList();
    if (digiDocs.isEmpty) {
      return 'You do not have any DigiLocker documents linked in Tribal Scholar Saathi yet. You can link them from the Document Wallet.';
    }

    final names = digiDocs.map((d) => '• ${d.name} (${d.category.label})').join('\n');
    return 'Your linked DigiLocker documents in Tribal Scholar Saathi:\n$names\n\nThese documents are government-verified and automatically accepted.';
  }

  static String _handleEligibility(String text, Student? student) {
    // 1. Identify if a specific scheme is referenced in the query or history
    Scholarship? scheme;
    if (text.contains('pre-matric') || text.contains('pre matric')) {
      scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
    } else if (text.contains('post-matric') || text.contains('post matric')) {
      scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
    } else if (text.contains('top class')) {
      scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
    } else if (text.contains('nfst') || text.contains('fellowship')) {
      scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
    } else if (text.contains('nos') || text.contains('overseas')) {
      scheme = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);
    }

    // 2. Specific question: "Why am I not eligible?"
    if (text.contains('why') && (text.contains('not') || text.contains('ineligible'))) {
      final target = scheme ?? ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
      final result = ScholarshipEligibilityService.evaluate(scholarship: target, student: student);
      return ScholarshipEligibilityService.explainFailedCriteria(result);
    }

    // 3. Specific question: "What am I missing?"
    if (text.contains('what') && text.contains('missing')) {
      final target = scheme ?? ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
      final result = ScholarshipEligibilityService.evaluate(scholarship: target, student: student);
      return ScholarshipEligibilityService.explainMissingInformation(result);
    }

    // 4. Targeted scheme check
    if (scheme != null) {
      if (student != null) {
        if (scheme.type == ScholarshipType.postMatric) {
          return 'Based on your student profile:\n'
              '• Category: ${student.category ?? 'ST'} (Eligible)\n'
              '• Course: ${student.currentCourse ?? 'Post-Matric course'} (Eligible)\n'
              '• State: ${student.state ?? 'Recognized'}\n'
              'You are eligible for the Post-Matric Scholarship for ST Students provided your annual family income is ₹2.50 Lakh or less and you have an Aadhaar-linked bank account.';
        }

        if (scheme.type == ScholarshipType.topClass) {
          if (student.institutionName != null &&
              (student.institutionName!.contains('NIT') || student.institutionName!.contains('IIT'))) {
            return 'Based on your admission at ${student.institutionName} (a notified premier institute):\n'
                '• Category: ${student.category ?? 'ST'} (Eligible)\n'
                '• Institution: ${student.institutionName} (Notified Premier Institute)\n'
                'You are eligible for the Top Class Education Scheme provided your annual family income does not exceed ₹6.00 Lakh.';
          }
        }

        final result = ScholarshipEligibilityService.evaluate(scholarship: scheme, student: student);
        final buffer = StringBuffer('Based on your student profile for ${scheme.name}:\n');
        for (final c in result.criteria) {
          final mark = c.status == CriterionStatus.satisfied
              ? '•'
              : c.status == CriterionStatus.notSatisfied
                  ? '✕'
                  : '?';
          final statusLabel = c.status == CriterionStatus.satisfied
              ? '(Eligible)'
              : c.status == CriterionStatus.notSatisfied
                  ? '(Ineligible)'
                  : '(Missing information)';
          buffer.writeln('$mark ${c.label}: ${c.reason ?? c.description} $statusLabel');
        }
        buffer.writeln('\n${result.summaryMessage}');
        return buffer.toString().trim();
      }

      final criteria = scheme.eligibilityCriteria.map((c) => '• $c').join('\n');
      return '${scheme.name} Eligibility:\n$criteria';
    }

    // 5. If query asks about a specific unnamed or unknown scheme:
    if (!text.contains('eligib') &&
        !text.contains('check my eligibility') &&
        !text.contains('am i eligible') &&
        !text.contains('can i apply') &&
        !text.contains('general') &&
        !text.contains('who can apply') &&
        !text.contains('qualification') &&
        !text.contains('criteria')) {
      return unavailableInfoMessage;
    }

    // 6. Conversational response for "Am I eligible?" / "Check my eligibility"
    if (student != null) {
      final buffer = StringBuffer('📋 **Automatic Eligibility Assessment for ${student.fullName}:**\n\n');
      for (final s in ScholarshipMockData.schemes) {
        final res = ScholarshipEligibilityService.evaluate(scholarship: s, student: student);
        final statusIcon = res.status == EligibilityStatus.eligible
            ? '✅'
            : (res.status == EligibilityStatus.notEligible ? '❌' : '⚠️');
        final statusLabel = res.status == EligibilityStatus.eligible
            ? 'Eligible'
            : (res.status == EligibilityStatus.notEligible ? 'Ineligible' : 'Needs Info');
        buffer.writeln('$statusIcon **${s.name}**: $statusLabel');
        buffer.writeln('   • ${res.summaryMessage}\n');
      }
      buffer.write('Official Source: Ministry of Tribal Affairs (MoTA) Guidelines (tribal.nic.in)');
      return buffer.toString().trim();
    }

    return 'General MoTA Scholarship Eligibility:\n'
        '1. Must belong to a notified Scheduled Tribe (ST) category.\n'
        '2. Enrolled in a recognized school, college, or university.\n'
        '3. Family annual income within scheme limits (₹2.50L for Pre/Post-Matric, ₹6.00L for Top Class/NOS; No income ceiling for NFST).\n'
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
    // 1. General scholarship concept
    if (text.contains('what is a scholarship') || text.contains('what is scholarship') || text.trim() == 'scholarship') {
      return 'A scholarship is non-repayable financial aid awarded to students to support their education. Unlike loans, scholarships do not have to be paid back. Under the Ministry of Tribal Affairs (MoTA), scholarships are provided to Scheduled Tribe (ST) students covering school education (Classes 9-10), higher studies (Class 11 to PG/Ph.D), premier institutions (IITs/IIMs), and overseas studies.';
    }

    // 2. What is DBT?
    if (text.contains('what is dbt') || text.contains('what does dbt mean') || text.trim() == 'dbt' || text.contains('explain dbt')) {
      return 'DBT stands for Direct Benefit Transfer. It is the Government of India\'s mechanism to disburse scholarship funds and stipends directly into the verified, Aadhaar-seeded bank accounts of eligible students via Public Financial Management System (PFMS). This eliminates intermediaries and ensures transparent, timely financial support.';
    }

    // 3. Official Schemes
    if (text.contains('pre-matric') || text.contains('pre matric')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.preMatric);
      return '### ${s.name}\n\n'
          '${s.detailedDescription}\n\n'
          '**Eligibility:**\n${s.eligibilityCriteria.map((c) => '• $c').join('\n')}\n\n'
          '**Required Documents:**\n${s.requiredDocuments.map((d) => '• $d').join('\n')}\n\n'
          '**Official Portal:** ${s.portalUrl}';
    }

    if (text.contains('post-matric') || text.contains('post matric')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.postMatric);
      return '### ${s.name}\n\n'
          '${s.detailedDescription}\n\n'
          '**Eligibility:**\n${s.eligibilityCriteria.map((c) => '• $c').join('\n')}\n\n'
          '**Required Documents:**\n${s.requiredDocuments.map((d) => '• $d').join('\n')}\n\n'
          '**Official Portal:** ${s.portalUrl}';
    }

    if (text.contains('top class')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.topClass);
      return '### ${s.name}\n\n'
          '${s.detailedDescription}\n\n'
          '**Eligibility:**\n${s.eligibilityCriteria.map((c) => '• $c').join('\n')}\n\n'
          '**Required Documents:**\n${s.requiredDocuments.map((d) => '• $d').join('\n')}\n\n'
          '**Official Portal:** ${s.portalUrl}';
    }

    if (text.contains('nfst') || text.contains('fellowship')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nfst);
      return '### ${s.name}\n\n'
          '${s.detailedDescription}\n\n'
          '**Eligibility:**\n${s.eligibilityCriteria.map((c) => '• $c').join('\n')}\n\n'
          '**Required Documents:**\n${s.requiredDocuments.map((d) => '• $d').join('\n')}\n\n'
          '**Official Portal:** ${s.portalUrl}';
    }

    if (text.contains('nos') || text.contains('overseas')) {
      final s = ScholarshipMockData.schemes.firstWhere((s) => s.type == ScholarshipType.nos);
      return '### ${s.name}\n\n'
          '${s.detailedDescription}\n\n'
          '**Eligibility:**\n${s.eligibilityCriteria.map((c) => '• $c').join('\n')}\n\n'
          '**Required Documents:**\n${s.requiredDocuments.map((d) => '• $d').join('\n')}\n\n'
          '**Official Portal:** ${s.portalUrl}';
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

    return 'Generally, scholarship eligibility and benefits depend on factors such as academic level, annual family income, category, and institution. For specific official rules, please refer to the latest official MoTA scheme guidelines.';
  }
}

