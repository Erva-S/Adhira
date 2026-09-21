import '../../core/enums/app_enums.dart';

/// Represents a payment / disbursement record.
class Payment {
  final String id;
  final String applicationId;
  final String scholarshipName;
  final PaymentStatus status;
  final double amount;
  final DateTime? sanctionedDate;
  final DateTime? disbursedDate;
  final String? transactionId;
  final String? bankRefNumber;
  final String? failureReason;
  final String? academicYear;
  final String? installmentLabel; // e.g., "Installment 1 of 2"

  const Payment({
    required this.id,
    required this.applicationId,
    required this.scholarshipName,
    required this.status,
    required this.amount,
    this.sanctionedDate,
    this.disbursedDate,
    this.transactionId,
    this.bankRefNumber,
    this.failureReason,
    this.academicYear,
    this.installmentLabel,
  });
}
