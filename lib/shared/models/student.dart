/// Represents a student / applicant in the system.
class Student {
  final String id;
  final String? authUserId;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? category;
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
  final String? educationLevel;
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
  final bool isDigiLockerLinked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Student({
    required this.id,
    this.authUserId,
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.dateOfBirth,
    this.gender,
    this.category = 'ST',
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
    this.educationLevel,
    this.currentCourse,
    this.currentYear,
    this.institutionName,
    this.institutionId,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.profileCompletionPercent = 0.0,
    this.isDigiLockerLinked = false,
    this.createdAt,
    this.updatedAt,
  });

  Student copyWith({
    String? id,
    String? authUserId,
    String? fullName,
    String? fatherName,
    String? motherName,
    DateTime? dateOfBirth,
    String? gender,
    String? category,
    String? aadhaarNumber,
    String? mobileNumber,
    String? email,
    String? photoUrl,
    String? tribeName,
    bool? isPVTG,
    String? stCertificateNumber,
    String? address,
    String? district,
    String? state,
    String? pinCode,
    String? educationLevel,
    String? currentCourse,
    String? currentYear,
    String? institutionName,
    String? institutionId,
    String? bankAccountNumber,
    String? ifscCode,
    String? bankName,
    double? profileCompletionPercent,
    bool? isDigiLockerLinked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      tribeName: tribeName ?? this.tribeName,
      isPVTG: isPVTG ?? this.isPVTG,
      stCertificateNumber: stCertificateNumber ?? this.stCertificateNumber,
      address: address ?? this.address,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      educationLevel: educationLevel ?? this.educationLevel,
      currentCourse: currentCourse ?? this.currentCourse,
      currentYear: currentYear ?? this.currentYear,
      institutionName: institutionName ?? this.institutionName,
      institutionId: institutionId ?? this.institutionId,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      profileCompletionPercent: profileCompletionPercent ?? this.profileCompletionPercent,
      isDigiLockerLinked: isDigiLockerLinked ?? this.isDigiLockerLinked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'category': category,
      'aadhaar_masked': aadhaarNumber,
      'mobile_number': mobileNumber,
      'email': email,
      'photo_url': photoUrl,
      'tribe_name': tribeName,
      'is_pvtg': isPVTG,
      'st_certificate_number': stCertificateNumber,
      'address': address,
      'district': district,
      'state': state,
      'pin_code': pinCode,
      'education_level': educationLevel,
      'course': currentCourse,
      'year_of_study': currentYear,
      'institution_name': institutionName,
      'institution_id': institutionId,
      'bank_account_number': bankAccountNumber,
      'ifsc_code': ifscCode,
      'bank_name': bankName,
      'profile_completion_percent': profileCompletionPercent,
      'is_digilocker_linked': isDigiLockerLinked,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toString() ?? '',
      authUserId: map['auth_user_id']?.toString(),
      fullName: map['full_name']?.toString() ?? '',
      fatherName: map['father_name']?.toString(),
      motherName: map['mother_name']?.toString(),
      dateOfBirth: map['date_of_birth'] != null ? DateTime.tryParse(map['date_of_birth'].toString()) : null,
      gender: map['gender']?.toString(),
      category: map['category']?.toString() ?? 'ST',
      aadhaarNumber: map['aadhaar_masked']?.toString() ?? map['aadhaar_number']?.toString(),
      mobileNumber: map['mobile_number']?.toString(),
      email: map['email']?.toString(),
      photoUrl: map['photo_url']?.toString(),
      tribeName: map['tribe_name']?.toString(),
      isPVTG: map['is_pvtg'] == true,
      stCertificateNumber: map['st_certificate_number']?.toString(),
      address: map['address']?.toString(),
      district: map['district']?.toString(),
      state: map['state']?.toString(),
      pinCode: map['pin_code']?.toString(),
      educationLevel: map['education_level']?.toString(),
      currentCourse: map['course']?.toString() ?? map['current_course']?.toString(),
      currentYear: map['year_of_study']?.toString() ?? map['current_year']?.toString(),
      institutionName: map['institution_name']?.toString(),
      institutionId: map['institution_id']?.toString(),
      bankAccountNumber: map['bank_account_number']?.toString(),
      ifscCode: map['ifsc_code']?.toString(),
      bankName: map['bank_name']?.toString(),
      profileCompletionPercent: (map['profile_completion_percent'] as num?)?.toDouble() ?? 0.0,
      isDigiLockerLinked: map['is_digilocker_linked'] == true,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }
}
