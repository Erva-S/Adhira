/// Represents a student / applicant in the system.
class Student {
  final String id;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? aadhaarNumber;
  final String? mobileNumber;
  final String? email;
  final String? photoUrl;

  // ── Tribal Details ────────────────────────────────────────────
  final String? tribeName;
  final bool isPVTG;
  final String? stCertificateNumber;

  // ── Address ───────────────────────────────────────────────────
  final String? address;
  final String? district;
  final String? state;
  final String? pinCode;

  // ── Education ─────────────────────────────────────────────────
  final String? currentCourse;
  final String? currentYear;
  final String? institutionName;
  final String? institutionId;

  // ── Bank Details ──────────────────────────────────────────────
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;

  // ── Profile Completion ────────────────────────────────────────
  final double profileCompletionPercent;

  const Student({
    required this.id,
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.dateOfBirth,
    this.gender,
    this.aadhaarNumber,
    this.mobileNumber,
    this.email,
    this.photoUrl,
    this.tribeName,
    this.isPVTG = false,
    this.stCertificateNumber,
    this.address,
    this.district,
    this.state,
    this.pinCode,
    this.currentCourse,
    this.currentYear,
    this.institutionName,
    this.institutionId,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.profileCompletionPercent = 0.0,
  });
}
