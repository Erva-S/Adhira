import '../../core/enums/app_enums.dart';

/// Represents a single verification check item.
class VerificationItem {
  final String id;
  final VerificationType type;
  final VerificationStatus status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? remarks;
  final String? sourceSystem; // e.g., 'UIDAI', 'e-District', 'AISHE'
  final bool isAutomatic;

  const VerificationItem({
    required this.id,
    required this.type,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.remarks,
    this.sourceSystem,
    this.isAutomatic = false,
  });
}
