import '../../core/enums/app_enums.dart';
import '../../shared/models/models.dart';

/// Deterministic, criteria-grounded eligibility evaluation service for MoTA scholarship schemes.
///
/// Uses official scheme rules and the authenticated user's actual profile as the source of truth.
/// Never guesses or invents criteria. If a required value is missing, marks that condition as
/// indeterminate and identifies the exact missing field.
class ScholarshipEligibilityService {
  ScholarshipEligibilityService._();

  static const String preliminaryDisclaimer =
      'Important: This is a preliminary eligibility check based on the information available in your profile '
      'and the official eligibility criteria stored for this scheme. Final eligibility is determined during official '
      'verification by the institution and State / Central Department.';

  /// Evaluates an authenticated [student] profile against a specific [scholarship] scheme.
  ///
  /// Optional overrides allow instant what-if recalculation when the user enters missing data
  /// without mutating global state.
  static EligibilityResult evaluate({
    required Scholarship scholarship,
    required Student? student,
    double? overrideIncome,
    String? overrideCourse,
    String? overrideInstitution,
  }) {
    if (student == null) {
      return EligibilityResult(
        scholarshipId: scholarship.id,
        scholarshipName: scholarship.name,
        status: EligibilityStatus.indeterminate,
        matchPercent: 0.0,
        criteria: [
          const EligibilityCriterion(
            label: 'User Profile',
            description: 'Authenticated student profile is required to evaluate eligibility.',
            status: CriterionStatus.indeterminate,
            reason: 'No authenticated profile loaded.',
          ),
        ],
        missingFields: ['Student Profile'],
        requiredDocuments: scholarship.requiredDocuments,
        disclaimer: preliminaryDisclaimer,
        summaryMessage: 'Eligibility could not be determined because no user profile was provided.',
      );
    }

    final criteria = <EligibilityCriterion>[];
    final missingFields = <String>[];

    final effectiveIncome = overrideIncome ?? student.annualFamilyIncome;
    final effectiveCourse = (overrideCourse ?? student.currentCourse ?? student.educationLevel ?? '').trim();
    final effectiveInstitution = (overrideInstitution ?? student.institutionName ?? '').trim();

    // ── 1. Category / Community Requirement (Mandatory ST for MoTA) ───────────
    final isST = student.category != null && student.category!.trim().toUpperCase() == 'ST';
    if (student.category == null || student.category!.trim().isEmpty) {
      criteria.add(const EligibilityCriterion(
        label: 'Community / Category (ST)',
        description: 'Must belong to a notified Scheduled Tribe (ST) category.',
        status: CriterionStatus.indeterminate,
        reason: 'Category details are missing from your profile.',
      ));
      missingFields.add('Social Category (ST)');
    } else if (isST) {
      final tribeInfo = student.tribeName != null && student.tribeName!.isNotEmpty
          ? ' (Tribe: ${student.tribeName})'
          : '';
      criteria.add(EligibilityCriterion(
        label: 'Community / Category (ST)',
        description: 'Must belong to a notified Scheduled Tribe (ST) category.',
        status: CriterionStatus.satisfied,
        reason: 'Verified as Scheduled Tribe (ST)$tribeInfo.',
      ));
    } else {
      criteria.add(EligibilityCriterion(
        label: 'Community / Category (ST)',
        description: 'Must belong to a notified Scheduled Tribe (ST) category.',
        status: CriterionStatus.notSatisfied,
        reason: 'This scheme is strictly reserved for Scheduled Tribe (ST) students. Your profile category is ${student.category}.',
      ));
    }

    // ── 2. Scheme-Specific Course / Academic Level ─────────────────────────────
    _evaluateCourseCriteria(
      scholarship: scholarship,
      student: student,
      course: effectiveCourse,
      institution: effectiveInstitution,
      criteria: criteria,
      missingFields: missingFields,
    );

    // ── 3. Scheme-Specific Institution Criteria (Top Class) ───────────────────
    if (scholarship.type == ScholarshipType.topClass) {
      _evaluatePremierInstitutionCriteria(
        institution: effectiveInstitution,
        criteria: criteria,
        missingFields: missingFields,
      );
    }

    // ── 4. Family Annual Income Limit ─────────────────────────────────────────
    _evaluateIncomeCriteria(
      scholarship: scholarship,
      income: effectiveIncome,
      criteria: criteria,
      missingFields: missingFields,
    );

    // ── 5. Age Limit (NFST: max 36 years as of July 1) ────────────────────────
    if (scholarship.type == ScholarshipType.nfst) {
      _evaluateAgeCriteria(
        student: student,
        criteria: criteria,
        missingFields: missingFields,
      );
    }

    // ── 6. Scheme-Specific Scope / Foreign Admission (NOS) ───────────────────
    if (scholarship.type == ScholarshipType.nos) {
      criteria.add(const EligibilityCriterion(
        label: 'Foreign University Admission',
        description: 'Must hold an unconditional admission offer from a Top 1,000 QS world-ranked foreign university.',
        status: CriterionStatus.indeterminate,
        reason: 'Requires foreign admission offer letter (to be verified at application upload stage).',
      ));
      criteria.add(const EligibilityCriterion(
        label: 'Valid Indian Passport',
        description: 'Must hold a valid Indian Passport.',
        status: CriterionStatus.indeterminate,
        reason: 'Passport details must be provided during document upload.',
      ));
    }

    // ── 7. DBT & Aadhaar Readiness ────────────────────────────────────────────
    final hasAadhaar = student.aadhaarNumber != null && student.aadhaarNumber!.isNotEmpty;
    final hasBank = student.bankAccountNumber != null && student.bankAccountNumber!.isNotEmpty;

    if (hasAadhaar && hasBank) {
      criteria.add(const EligibilityCriterion(
        label: 'Aadhaar & Bank Account (DBT)',
        description: 'Must hold an active bank account linked with Aadhaar and mobile for DBT.',
        status: CriterionStatus.satisfied,
        reason: 'Aadhaar and bank account are registered in your profile.',
      ));
    } else {
      final missingDbt = <String>[];
      if (!hasAadhaar) missingDbt.add('Aadhaar Number');
      if (!hasBank) missingDbt.add('Bank Account Details');
      criteria.add(EligibilityCriterion(
        label: 'Aadhaar & Bank Account (DBT)',
        description: 'Must hold an active bank account linked with Aadhaar and mobile for DBT.',
        status: CriterionStatus.indeterminate,
        reason: 'Missing from profile: ${missingDbt.join(', ')}.',
      ));
      missingFields.addAll(missingDbt);
    }

    // ── Overall Status Calculation ────────────────────────────────────────────
    final hasFailed = criteria.any((c) => c.status == CriterionStatus.notSatisfied);
    final hasIndeterminate = criteria.any((c) => c.status == CriterionStatus.indeterminate);

    EligibilityStatus overallStatus;
    if (hasFailed) {
      overallStatus = EligibilityStatus.notEligible;
    } else if (hasIndeterminate) {
      overallStatus = EligibilityStatus.indeterminate;
    } else {
      overallStatus = EligibilityStatus.eligible;
    }

    final satisfiedCount = criteria.where((c) => c.status == CriterionStatus.satisfied).length;
    final matchPercent = criteria.isNotEmpty ? satisfiedCount / criteria.length : 0.0;

    String summaryMessage;
    switch (overallStatus) {
      case EligibilityStatus.eligible:
        summaryMessage =
            'Based on the information available in your profile and the eligibility criteria stored for this scheme, you appear eligible.';
        break;
      case EligibilityStatus.notEligible:
        summaryMessage =
            'Based on the official eligibility criteria stored for this scheme, you do not meet one or more conditions.';
        break;
      case EligibilityStatus.indeterminate:
        summaryMessage =
            'Eligibility could not be fully determined because some required information is missing from your profile.';
        break;
    }

    return EligibilityResult(
      scholarshipId: scholarship.id,
      scholarshipName: scholarship.name,
      status: overallStatus,
      matchPercent: matchPercent,
      criteria: criteria,
      missingFields: missingFields,
      requiredDocuments: scholarship.requiredDocuments,
      disclaimer: preliminaryDisclaimer,
      summaryMessage: summaryMessage,
    );
  }

  // ── Helper Criterion Evaluators ─────────────────────────────────────────────

  static void _evaluateCourseCriteria({
    required Scholarship scholarship,
    required Student student,
    required String course,
    required String institution,
    required List<EligibilityCriterion> criteria,
    required List<String> missingFields,
  }) {
    final lowerCourse = course.toLowerCase();

    switch (scholarship.type) {
      case ScholarshipType.preMatric:
        final isPreMatric = lowerCourse.contains('class 9') ||
            lowerCourse.contains('class 10') ||
            lowerCourse.contains('class ix') ||
            lowerCourse.contains('class x') ||
            lowerCourse.contains('9th') ||
            lowerCourse.contains('10th');

        if (course.isEmpty) {
          criteria.add(const EligibilityCriterion(
            label: 'Academic Level (Classes 9 & 10)',
            description: 'Must be studying in Class IX or Class X in a Government or recognized school.',
            status: CriterionStatus.indeterminate,
            reason: 'Academic class/course details are not recorded in your profile.',
          ));
          missingFields.add('Current Class (IX or X)');
        } else if (isPreMatric) {
          criteria.add(EligibilityCriterion(
            label: 'Academic Level (Classes 9 & 10)',
            description: 'Must be studying in Class IX or Class X in a Government or recognized school.',
            status: CriterionStatus.satisfied,
            reason: 'Enrolled in eligible Class IX/X ($course).',
          ));
        } else {
          criteria.add(EligibilityCriterion(
            label: 'Academic Level (Classes 9 & 10)',
            description: 'Must be studying in Class IX or Class X in a Government or recognized school.',
            status: CriterionStatus.notSatisfied,
            reason: 'Pre-Matric is strictly for Class IX and X. Your profile indicates: $course.',
          ));
        }
        break;

      case ScholarshipType.postMatric:
        final isPreMatricOnly = (lowerCourse.contains('class 9') ||
                lowerCourse.contains('class 10') ||
                lowerCourse.contains('class ix') ||
                lowerCourse.contains('class x')) &&
            !lowerCourse.contains('class 11') &&
            !lowerCourse.contains('class 12');

        if (course.isEmpty) {
          criteria.add(const EligibilityCriterion(
            label: 'Education Level (Post-Matric)',
            description: 'Must have passed Matriculation (Class X) and be enrolled in Class XI onwards or Higher Education.',
            status: CriterionStatus.indeterminate,
            reason: 'Current course details are missing from your profile.',
          ));
          missingFields.add('Current Course / Class');
        } else if (isPreMatricOnly) {
          criteria.add(EligibilityCriterion(
            label: 'Education Level (Post-Matric)',
            description: 'Must have passed Matriculation (Class X) and be enrolled in Class XI onwards or Higher Education.',
            status: CriterionStatus.notSatisfied,
            reason: 'Post-Matric requires completion of Class X. Your current course is: $course.',
          ));
        } else {
          criteria.add(EligibilityCriterion(
            label: 'Education Level (Post-Matric)',
            description: 'Must have passed Matriculation (Class X) and be enrolled in Class XI onwards or Higher Education.',
            status: CriterionStatus.satisfied,
            reason: 'Enrolled in post-matric studies ($course).',
          ));
        }
        break;

      case ScholarshipType.topClass:
        final isHigherEd = lowerCourse.contains('b.tech') ||
            lowerCourse.contains('btech') ||
            lowerCourse.contains('mbbs') ||
            lowerCourse.contains('bachelor') ||
            lowerCourse.contains('master') ||
            lowerCourse.contains('degree') ||
            lowerCourse.contains('undergraduate') ||
            lowerCourse.contains('postgraduate') ||
            student.educationLevel?.toLowerCase().contains('undergraduate') == true ||
            student.educationLevel?.toLowerCase().contains('postgraduate') == true;

        if (course.isEmpty) {
          criteria.add(const EligibilityCriterion(
            label: 'Academic Course Level (UG / PG)',
            description: 'Pursuing Graduate or Post-Graduate degree courses.',
            status: CriterionStatus.indeterminate,
            reason: 'Course level is not specified in profile.',
          ));
          missingFields.add('Course Level (UG/PG)');
        } else if (isHigherEd) {
          criteria.add(EligibilityCriterion(
            label: 'Academic Course Level (UG / PG)',
            description: 'Pursuing Graduate or Post-Graduate degree courses.',
            status: CriterionStatus.satisfied,
            reason: 'Enrolled in eligible degree program ($course).',
          ));
        } else {
          criteria.add(EligibilityCriterion(
            label: 'Academic Course Level (UG / PG)',
            description: 'Pursuing Graduate or Post-Graduate degree courses.',
            status: CriterionStatus.notSatisfied,
            reason: 'Top Class Scheme is for Graduate and Post-Graduate degrees. Current: $course.',
          ));
        }
        break;

      case ScholarshipType.nfst:
        final isResearch = lowerCourse.contains('ph.d') ||
            lowerCourse.contains('phd') ||
            lowerCourse.contains('m.phil') ||
            lowerCourse.contains('mphil') ||
            lowerCourse.contains('fellowship') ||
            lowerCourse.contains('doctorate') ||
            lowerCourse.contains('research');

        if (course.isEmpty) {
          criteria.add(const EligibilityCriterion(
            label: 'Research Enrollment (M.Phil / Ph.D)',
            description: 'Must be enrolled in regular and full-time M.Phil or Ph.D in a recognized Indian university/institute.',
            status: CriterionStatus.indeterminate,
            reason: 'Current academic level not specified in profile.',
          ));
          missingFields.add('M.Phil / Ph.D Enrollment Details');
        } else if (isResearch) {
          criteria.add(EligibilityCriterion(
            label: 'Research Enrollment (M.Phil / Ph.D)',
            description: 'Must be enrolled in regular and full-time M.Phil or Ph.D in a recognized Indian university/institute.',
            status: CriterionStatus.satisfied,
            reason: 'Enrolled in eligible research degree ($course).',
          ));
        } else {
          criteria.add(EligibilityCriterion(
            label: 'Research Enrollment (M.Phil / Ph.D)',
            description: 'Must be enrolled in regular and full-time M.Phil or Ph.D in a recognized Indian university/institute.',
            status: CriterionStatus.notSatisfied,
            reason: 'NFST is strictly for full-time M.Phil / Ph.D research scholars. Your current course is: $course.',
          ));
        }
        break;

      case ScholarshipType.nos:
        final isAbroadCandidate = lowerCourse.contains('master') ||
            lowerCourse.contains('ph.d') ||
            lowerCourse.contains('phd') ||
            lowerCourse.contains('postgraduate') ||
            student.educationLevel?.toLowerCase().contains('postgraduate') == true ||
            student.educationLevel?.toLowerCase().contains('doctorate') == true;

        if (course.isEmpty) {
          criteria.add(const EligibilityCriterion(
            label: 'Degree Level (Masters / Ph.D Abroad)',
            description: 'Pursuing Masters or Ph.D courses abroad (Post-Doctoral omitted from 2026-27 onwards).',
            status: CriterionStatus.indeterminate,
            reason: 'Course details missing from profile.',
          ));
          missingFields.add('Intended Masters / Ph.D Course Abroad');
        } else if (isAbroadCandidate) {
          criteria.add(EligibilityCriterion(
            label: 'Degree Level (Masters / Ph.D Abroad)',
            description: 'Pursuing Masters or Ph.D courses abroad (Post-Doctoral omitted from 2026-27 onwards).',
            status: CriterionStatus.satisfied,
            reason: 'Qualifies for Masters/Ph.D level studies ($course).',
          ));
        } else {
          criteria.add(EligibilityCriterion(
            label: 'Degree Level (Masters / Ph.D Abroad)',
            description: 'Pursuing Masters or Ph.D courses abroad (Post-Doctoral omitted from 2026-27 onwards).',
            status: CriterionStatus.notSatisfied,
            reason: 'National Overseas Scholarship is strictly for Masters and Ph.D degrees. Current: $course.',
          ));
        }
        break;
    }
  }

  static void _evaluatePremierInstitutionCriteria({
    required String institution,
    required List<EligibilityCriterion> criteria,
    required List<String> missingFields,
  }) {
    if (institution.isEmpty) {
      criteria.add(const EligibilityCriterion(
        label: 'Premier Notified Institution',
        description: 'Must have secured admission on merit in one of the 252 notified premier institutes (IITs, NITs, IIMs, AIIMS, NLUs, etc.).',
        status: CriterionStatus.indeterminate,
        reason: 'Institution name is not recorded in your profile.',
      ));
      missingFields.add('Notified Premier Institution Name');
      return;
    }

    final lower = institution.toLowerCase();
    final isPremier = lower.contains('nit') ||
        lower.contains('iit') ||
        lower.contains('iim') ||
        lower.contains('aiims') ||
        lower.contains('nlu') ||
        lower.contains('national law') ||
        lower.contains('national institute of technology') ||
        lower.contains('indian institute of technology') ||
        lower.contains('indian institute of management') ||
        lower.contains('iiit') ||
        lower.contains('iiser') ||
        lower.contains('svnit');

    if (isPremier) {
      criteria.add(EligibilityCriterion(
        label: 'Premier Notified Institution',
        description: 'Must have secured admission on merit in one of the 252 notified premier institutes.',
        status: CriterionStatus.satisfied,
        reason: 'Admitted in notified premier institute ($institution).',
      ));
    } else {
      criteria.add(EligibilityCriterion(
        label: 'Premier Notified Institution',
        description: 'Must have secured admission on merit in one of the 252 notified premier institutes (IITs, NITs, IIMs, AIIMS, NLUs, etc.).',
        status: CriterionStatus.notSatisfied,
        reason: '$institution is not in the list of 252 notified premier institutes for Top Class Scheme.',
      ));
    }
  }

  static void _evaluateIncomeCriteria({
    required Scholarship scholarship,
    required double? income,
    required List<EligibilityCriterion> criteria,
    required List<String> missingFields,
  }) {
    // NFST has NO income ceiling per official MoTA guidelines!
    if (scholarship.type == ScholarshipType.nfst) {
      criteria.add(const EligibilityCriterion(
        label: 'Family Annual Income',
        description: 'NO INCOME CRITERIA: There is no income ceiling for National Fellowship (NFST).',
        status: CriterionStatus.satisfied,
        reason: 'Scheme guidelines state there is no family income limit for NFST.',
      ));
      return;
    }

    final double ceiling = (scholarship.type == ScholarshipType.topClass || scholarship.type == ScholarshipType.nos)
        ? 600000.0 // ₹6.00 Lakh
        : 250000.0; // ₹2.50 Lakh for Pre & Post-Matric

    final ceilingLabel = ceiling == 600000.0 ? '₹6.00 Lakh' : '₹2.50 Lakh';

    if (income == null) {
      criteria.add(EligibilityCriterion(
        label: 'Family Annual Income (Ceiling: $ceilingLabel)',
        description: 'Family annual income from all sources must not exceed $ceilingLabel per annum.',
        status: CriterionStatus.indeterminate,
        reason: 'Annual family income is missing from your profile.',
      ));
      missingFields.add('Annual Family Income');
    } else if (income <= ceiling) {
      final formattedIncome = '₹${income.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
      criteria.add(EligibilityCriterion(
        label: 'Family Annual Income (Ceiling: $ceilingLabel)',
        description: 'Family annual income from all sources must not exceed $ceilingLabel per annum.',
        status: CriterionStatus.satisfied,
        reason: 'Your annual income ($formattedIncome) is within the $ceilingLabel ceiling.',
      ));
    } else {
      final formattedIncome = '₹${income.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
      criteria.add(EligibilityCriterion(
        label: 'Family Annual Income (Ceiling: $ceilingLabel)',
        description: 'Family annual income from all sources must not exceed $ceilingLabel per annum.',
        status: CriterionStatus.notSatisfied,
        reason: 'Your annual income ($formattedIncome) exceeds the scheme ceiling of $ceilingLabel.',
      ));
    }
  }

  static void _evaluateAgeCriteria({
    required Student student,
    required List<EligibilityCriterion> criteria,
    required List<String> missingFields,
  }) {
    if (student.dateOfBirth == null) {
      criteria.add(const EligibilityCriterion(
        label: 'Age Limit (Max 36 Years)',
        description: 'Maximum age of 36 years as on 1st July of the selection year.',
        status: CriterionStatus.indeterminate,
        reason: 'Date of birth is missing from your profile.',
      ));
      missingFields.add('Date of Birth');
      return;
    }

    final dob = student.dateOfBirth!;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    if (age <= 36) {
      criteria.add(EligibilityCriterion(
        label: 'Age Limit (Max 36 Years)',
        description: 'Maximum age of 36 years as on 1st July of the selection year.',
        status: CriterionStatus.satisfied,
        reason: 'Age is $age years (within the 36-year limit).',
      ));
    } else {
      criteria.add(EligibilityCriterion(
        label: 'Age Limit (Max 36 Years)',
        description: 'Maximum age of 36 years as on 1st July of the selection year.',
        status: CriterionStatus.notSatisfied,
        reason: 'Age is $age years, which exceeds the maximum ceiling of 36 years.',
      ));
    }
  }

  /// Explains the exact failure reasons in human-friendly conversational language.
  static String explainFailedCriteria(EligibilityResult result) {
    final failed = result.criteria.where((c) => c.status == CriterionStatus.notSatisfied).toList();
    if (failed.isEmpty) {
      return 'You have not failed any eligibility criteria for ${result.scholarshipName}.';
    }

    final buffer = StringBuffer('You currently do not meet the following criteria for ${result.scholarshipName}:\n');
    for (final c in failed) {
      buffer.writeln('✕ ${c.label}: ${c.reason ?? c.description}');
    }
    return buffer.toString().trim();
  }

  /// Explains only the missing information needed to determine eligibility.
  static String explainMissingInformation(EligibilityResult result) {
    final indeterminate = result.criteria.where((c) => c.status == CriterionStatus.indeterminate).toList();
    if (indeterminate.isEmpty && result.missingFields.isEmpty) {
      return 'There is no missing information. Your profile has all the data required to evaluate ${result.scholarshipName}.';
    }

    final buffer = StringBuffer('The following information is missing to determine your eligibility for ${result.scholarshipName}:\n');
    for (final c in indeterminate) {
      buffer.writeln('? ${c.label}: ${c.reason ?? c.description}');
    }
    return buffer.toString().trim();
  }

  /// Evaluates all available schemes for a student and returns a map of schemeId -> result.
  static Map<String, EligibilityResult> evaluateAll({
    required List<Scholarship> schemes,
    required Student? student,
  }) {
    final results = <String, EligibilityResult>{};
    for (final scheme in schemes) {
      results[scheme.id] = evaluate(scholarship: scheme, student: student);
    }
    return results;
  }
}
