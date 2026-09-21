import '../../core/enums/app_enums.dart';

/// Represents a payment / disbursement record under MoTA DBT.
class Payment {
  final String id;
  final String applicationId;
  final String? userId; // Foreign key to users.id
  final String scholarshipName;
  final PaymentStatus status;
  final DbtStatus dbtStatus;
  final double amount;
  final DateTime? sanctionedDate;
  final DateTime? disbursedDate;
  final String? transactionId;
  final String? bankRefNumber;
  final String? referenceNumber; // PFMS Reference
  final String? transactionReference; // Bank UTR
  final String? failureReason;
  final String? academicYear;
  final String? installmentLabel; // e.g., "Installment 1 of 2"
  final DateTime? createdAt;

  const Payment({
    required this.id,
    required this.applicationId,
    this.userId,
    required this.scholarshipName,
    required this.status,
    this.dbtStatus = DbtStatus.dbtInitiated,
    required this.amount,
    this.sanctionedDate,
    this.disbursedDate,
    this.transactionId,
    this.bankRefNumber,
    this.referenceNumber,
    this.transactionReference,
    this.failureReason,
    this.academicYear,
    this.installmentLabel,
    this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? applicationId,
    String? userId,
    String? scholarshipName,
    PaymentStatus? status,
    DbtStatus? dbtStatus,
    double? amount,
    DateTime? sanctionedDate,
    DateTime? disbursedDate,
    String? transactionId,
    String? bankRefNumber,
    String? referenceNumber,
    String? transactionReference,
    String? failureReason,
    String? academicYear,
    String? installmentLabel,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      scholarshipName: scholarshipName ?? this.scholarshipName,
      status: status ?? this.status,
      dbtStatus: dbtStatus ?? this.dbtStatus,
      amount: amount ?? this.amount,
      sanctionedDate: sanctionedDate ?? this.sanctionedDate,
      disbursedDate: disbursedDate ?? this.disbursedDate,
      transactionId: transactionId ?? this.transactionId,
      bankRefNumber: bankRefNumber ?? this.bankRefNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      transactionReference: transactionReference ?? this.transactionReference,
      failureReason: failureReason ?? this.failureReason,
      academicYear: academicYear ?? this.academicYear,
      installmentLabel: installmentLabel ?? this.installmentLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'user_id': userId,
      'scholarship_name': scholarshipName,
      'status': status.name,
      'dbt_status': dbtStatus.name,
      'amount': amount,
      'sanctioned_date': sanctionedDate?.toIso8601String(),
      'disbursed_date': disbursedDate?.toIso8601String(),
      'transaction_id': transactionId,
      'bank_ref_number': bankRefNumber,
      'reference_number': referenceNumber,
      'transaction_reference': transactionReference,
      'failure_reason': failureReason,
      'academic_year': academicYear,
      'installment_label': installmentLabel,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString() ?? '',
      applicationId: map['application_id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      scholarshipName: map['scholarship_name']?.toString() ?? 'MoTA Scholarship',
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == map['status'] || s.label == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      dbtStatus: DbtStatus.values.firstWhere(
        (d) => d.name == map['dbt_status'] || d.label == map['dbt_status'],
        orElse: () => DbtStatus.dbtInitiated,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      sanctionedDate: map['sanctioned_date'] != null ? DateTime.tryParse(map['sanctioned_date'].toString()) : null,
      disbursedDate: map['disbursed_date'] != null ? DateTime.tryParse(map['disbursed_date'].toString()) : null,
      transactionId: map['transaction_id']?.toString(),
      bankRefNumber: map['bank_ref_number']?.toString(),
      referenceNumber: map['reference_number']?.toString(),
      transactionReference: map['transaction_reference']?.toString(),
      failureReason: map['failure_reason']?.toString(),
      academicYear: map['academic_year']?.toString(),
      installmentLabel: map['installment_label']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }
}
