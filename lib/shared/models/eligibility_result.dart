/// Represents the result of an eligibility check.
class EligibilityResult {
  final String scholarshipId;
  final String scholarshipName;
  final bool isEligible;
  final double matchPercent; // 0.0 to 1.0
  final List<EligibilityCriterion> criteria;
  final String? disclaimer;

  const EligibilityResult({
    required this.scholarshipId,
    required this.scholarshipName,
    required this.isEligible,
    required this.matchPercent,
    this.criteria = const [],
    this.disclaimer,
  });
}

/// A single eligibility criterion and whether it's met.
class EligibilityCriterion {
  final String label;
  final String description;
  final bool isMet;
  final String? reason;

  const EligibilityCriterion({
    required this.label,
    required this.description,
    required this.isMet,
    this.reason,
  });
}
