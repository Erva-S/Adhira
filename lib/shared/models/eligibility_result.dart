/// Status of an overall scholarship eligibility check.
enum EligibilityStatus {
  eligible,
  notEligible,
  indeterminate,
}

/// Status of a specific eligibility criterion.
enum CriterionStatus {
  satisfied,
  notSatisfied,
  indeterminate,
}

/// Represents the result of an eligibility check against official scheme rules.
class EligibilityResult {
  final String scholarshipId;
  final String scholarshipName;
  final EligibilityStatus status;
  final double matchPercent; // 0.0 to 1.0
  final List<EligibilityCriterion> criteria;
  final List<String> missingFields;
  final List<String> requiredDocuments;
  final String? disclaimer;
  final String? summaryMessage;

  const EligibilityResult({
    required this.scholarshipId,
    required this.scholarshipName,
    required this.status,
    required this.matchPercent,
    this.criteria = const [],
    this.missingFields = const [],
    this.requiredDocuments = const [],
    this.disclaimer,
    this.summaryMessage,
  });

  /// Backward-compatible getter for legacy code checking boolean eligibility.
  bool get isEligible => status == EligibilityStatus.eligible;

  /// Returns true if any criterion is unable to be evaluated due to missing information.
  bool get hasMissingInformation => status == EligibilityStatus.indeterminate || missingFields.isNotEmpty;
}

/// A single eligibility criterion and whether it's satisfied, not satisfied, or unable to determine.
class EligibilityCriterion {
  final String label;
  final String description;
  final CriterionStatus status;
  final String? reason;

  const EligibilityCriterion({
    required this.label,
    required this.description,
    required this.status,
    this.reason,
  });

  /// Backward-compatible helper returning true only if satisfied.
  bool get isMet => status == CriterionStatus.satisfied;

  /// Returns true if information is missing or indeterminate.
  bool get isIndeterminate => status == CriterionStatus.indeterminate;

  /// Returns true if explicitly failed.
  bool get isFailed => status == CriterionStatus.notSatisfied;
}
