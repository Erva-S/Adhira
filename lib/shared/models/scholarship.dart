import '../../core/enums/app_enums.dart';

/// Represents a scholarship scheme.
class Scholarship {
  final String id;
  final ScholarshipType type;
  final String name;
  final String description;
  final String? detailedDescription;
  final double? maxAmount;
  final String? duration;
  final List<String> eligibilityCriteria;
  final List<String> requiredDocuments;
  final DateTime? applicationDeadline;
  final bool isOpen;
  final String? portalUrl;
  final String? iconAsset;

  const Scholarship({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.detailedDescription,
    this.maxAmount,
    this.duration,
    this.eligibilityCriteria = const [],
    this.requiredDocuments = const [],
    this.applicationDeadline,
    this.isOpen = true,
    this.portalUrl,
    this.iconAsset,
  });
}
