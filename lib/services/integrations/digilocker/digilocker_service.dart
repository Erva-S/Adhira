import 'dart:convert';
import 'package:flutter/services.dart';

/// Integration status of an external government gateway.
enum IntegrationStatus {
  mockDemo('DigiLocker Integration — Demo'),
  readyForCredentials('Integration-Ready (Awaiting API Credentials)'),
  connected('Live Connected');

  final String label;
  const IntegrationStatus(this.label);
}

/// Represents a document available from the citizen's DigiLocker account.
class DigiLockerDocument {
  final String uri;
  final String name;
  final String issuer;
  final String issuerShort;
  final String docType;
  final DateTime? issuedDate;
  final bool isVerified;
  final String description;
  final bool requiredForScholarship;
  final String? maskedNumber;
  final String? assetImagePath;

  const DigiLockerDocument({
    required this.uri,
    required this.name,
    required this.issuer,
    required this.issuerShort,
    required this.docType,
    this.issuedDate,
    this.isVerified = false,
    this.description = '',
    this.requiredForScholarship = false,
    this.maskedNumber,
    this.assetImagePath,
  });

  factory DigiLockerDocument.fromJson(Map<String, dynamic> json) {
    return DigiLockerDocument(
      uri: json['uri'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      issuerShort: json['issuer_short'] as String? ?? json['issuer'] as String,
      docType: json['doc_type'] as String,
      issuedDate: json['issued_date'] != null
          ? DateTime.tryParse(json['issued_date'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      requiredForScholarship: json['required_for_scholarship'] as bool? ?? false,
      maskedNumber: json['masked_number'] as String?,
      assetImagePath: json['asset_image_path'] as String?,
    );
  }
}

/// Document data fetched from DigiLocker.
class DigiLockerDocumentData {
  final String uri;
  final String name;
  final String mimeType;
  final Uint8List bytes;

  const DigiLockerDocumentData({
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
}

/// Represents citizen profile information authorized and retrieved from DigiLocker.
class DigiLockerUserProfile {
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? category;
  final String? tribeName;
  final String? stCertificateNumber;
  final String? address;
  final String? district;
  final String? state;
  final String? pinCode;
  final String? institutionName;
  final String? institutionId;
  final String? currentCourse;
  final String? currentYear;
  final String? educationLevel;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? maskedAadhaar;
  final String? mobileNumber;
  final String? email;
  final bool isVerified;
  final DateTime fetchedAt;

  const DigiLockerUserProfile({
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.dateOfBirth,
    this.gender,
    this.category = 'ST',
    this.tribeName,
    this.stCertificateNumber,
    this.address,
    this.district,
    this.state,
    this.pinCode,
    this.institutionName,
    this.institutionId,
    this.currentCourse,
    this.currentYear,
    this.educationLevel,
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.maskedAadhaar,
    this.mobileNumber,
    this.email,
    this.isVerified = true,
    required this.fetchedAt,
  });
}

/// Abstract DigiLocker service boundary.
///
/// Clean service interface with connect(), disconnect(),
/// getAvailableDocuments(), importDocument(), and fetchUserProfile().
abstract class DigiLockerService {
  IntegrationStatus get status;
  bool get isConnected;

  /// Connect to DigiLocker OAuth gateway.
  Future<bool> connect();

  /// Disconnect DigiLocker session.
  Future<void> disconnect();

  /// Fetch list of available certificates from user's DigiLocker.
  Future<List<DigiLockerDocument>> getAvailableDocuments();

  /// Import a specific document and return its data for saving into student's wallet.
  Future<DigiLockerDocumentData?> importDocument(String docUri, String userId);

  /// Fetch citizen profile details authorized through DigiLocker.
  Future<DigiLockerUserProfile> fetchUserProfile(String userId, {String? phoneNumber});
}

/// Simulated DigiLocker service for prototype & demonstration.
///
/// Clearly identified as Demo Mode — never claims to be a live government API.
/// Loads document list from [assets/jsons/digilocker_documents.json].
class MockDigiLockerService implements DigiLockerService {
  bool _connected = false;
  List<DigiLockerDocument>? _cachedDocuments;

  @override
  IntegrationStatus get status => IntegrationStatus.mockDemo;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> connect() async {
    // Simulate OAuth handshake delay (demo only)
    await Future.delayed(const Duration(milliseconds: 900));
    _connected = true;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _cachedDocuments = null;
  }

  @override
  Future<DigiLockerUserProfile> fetchUserProfile(String userId, {String? phoneNumber}) async {
    // Realistic simulated latency for identity & certificate retrieval from DigiLocker
    await Future.delayed(const Duration(milliseconds: 1000));

    // CRITICAL CONDITION: These details must be returned ONLY when the authenticated mobile number is:
    // 9898418407. For any other mobile number / user, preserve the existing default behavior.
    final cleanPhone = phoneNumber?.replaceAll(RegExp(r'\D'), '');
    final isErva = cleanPhone == '9898418407' ||
        cleanPhone == '919898418407' ||
        userId.contains('9898418407');

    if (isErva) {
      return DigiLockerUserProfile(
        fullName: 'Erva Savaliya',
        fatherName: 'Dilip Savaliya',
        motherName: 'Vaishali Savaliya',
        dateOfBirth: DateTime(2007, 4, 18),
        gender: 'Female',
        category: 'ST',
        tribeName: 'Gamit',
        stCertificateNumber: 'ST/GJ/2023/88921',
        address: 'Near Station Road, Valsad',
        district: 'Valsad',
        state: 'Gujarat',
        pinCode: '396195',
        institutionName: 'NIT Surat (SVNIT)',
        institutionId: 'AISHE-U-0149',
        currentCourse: 'B.Tech Computer Science',
        currentYear: '1st Year',
        educationLevel: 'Undergraduate',
        bankAccountNumber: '987654321012',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        maskedAadhaar: 'XXXX-XXXX-4892',
        mobileNumber: '9898418407',
        email: 'erva.savaliya.20@gmail.com',
        isVerified: true,
        fetchedAt: DateTime.now(),
      );
    }

    // Default ST scholar profile for all other users / mobile numbers
    return DigiLockerUserProfile(
      fullName: 'Rajesh Soren',
      fatherName: 'Manoj Soren',
      motherName: 'Sunita Soren',
      dateOfBirth: DateTime(2004, 8, 14),
      gender: 'Male',
      category: 'ST',
      tribeName: 'Santal',
      stCertificateNumber: 'ST/OD/2023/88921',
      address: 'Plot 42, Ward 3, Baripada',
      district: 'Mayurbhanj',
      state: 'Odisha',
      pinCode: '757001',
      institutionName: 'NIT Rourkela',
      institutionId: 'AISHE-U-0355',
      currentCourse: 'B.Tech Computer Science',
      currentYear: '2nd Year',
      educationLevel: 'Undergraduate',
      bankAccountNumber: '987654321012',
      ifscCode: 'SBIN0001234',
      bankName: 'State Bank of India',
      maskedAadhaar: 'XXXX-XXXX-4892',
      mobileNumber: cleanPhone ?? '9876543210',
      email: 'rajesh.soren@nitrkl.ac.in',
      isVerified: true,
      fetchedAt: DateTime.now(),
    );
  }

  @override
  Future<List<DigiLockerDocument>> getAvailableDocuments() async {
    if (!_connected) {
      await connect();
    }

    // Return cached documents if already loaded
    if (_cachedDocuments != null) return _cachedDocuments!;

    // Load demo documents from bundled JSON asset (no network call)
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final jsonString = await rootBundle
          .loadString('assets/jsons/digilocker_documents.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final docList = (jsonData['documents'] as List<dynamic>)
          .map((e) => DigiLockerDocument.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedDocuments = docList;
      return docList;
    } catch (_) {
      // Fallback to inline demo data if asset loading fails
      _cachedDocuments = _fallbackDocuments;
      return _cachedDocuments!;
    }
  }

  @override
  Future<DigiLockerDocumentData?> importDocument(
      String docUri, String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulated document payload — demo data only, not a real government file
    final dummyBytes = Uint8List.fromList(
      '[DEMO] MoTA DigiLocker Document [$docUri] — Prototype Data for $userId'
          .codeUnits,
    );

    final docs = _cachedDocuments ?? _fallbackDocuments;
    final doc = docs.firstWhere(
      (d) => d.uri == docUri,
      orElse: () => DigiLockerDocument(
        uri: docUri,
        name: docUri.split('/').last.replaceAll('_', ' ').toUpperCase(),
        issuer: 'Government of India',
        issuerShort: 'GoI',
        docType: 'GENERIC',
      ),
    );

    return DigiLockerDocumentData(
      uri: docUri,
      name: doc.name,
      mimeType: 'application/pdf',
      bytes: dummyBytes,
    );
  }

  static final List<DigiLockerDocument> _fallbackDocuments = [
    DigiLockerDocument(
      uri: 'dl://uidai/aadhaar_card',
      name: 'Aadhaar Card',
      issuer: 'Unique Identification Authority of India (UIDAI)',
      issuerShort: 'UIDAI',
      docType: 'ADHAR',
      issuedDate: DateTime(2023, 11, 1),
      isVerified: true,
      description: 'National Identity Document — Biometric verified',
      requiredForScholarship: true,
      maskedNumber: 'XXXX XXXX 4401',
      assetImagePath: 'assets/images/aadhaar_card.png',
    ),
    DigiLockerDocument(
      uri: 'dl://gujarat/caste_cert',
      name: 'Caste Certificate (SEBC / ST)',
      issuer: 'Mamlatdar Office, Surat City, Govt. of Gujarat',
      issuerShort: 'Govt. of Gujarat',
      docType: 'CASTE_ST',
      issuedDate: DateTime(2023, 1, 4),
      isVerified: true,
      description: 'Caste Certificate for Educational & State Benefits',
      requiredForScholarship: true,
      maskedNumber: 'Certificate No. 809/XXXX',
      assetImagePath: 'assets/images/caste_certificate.jpg',
    ),
    DigiLockerDocument(
      uri: 'dl://cbse/class12_marksheet',
      name: 'Class 12 Passing Certificate & Marksheet',
      issuer: 'Central Board of Secondary Education (CBSE)',
      issuerShort: 'CBSE',
      docType: 'ACADEMIC_12',
      issuedDate: DateTime(2025, 5, 13),
      isVerified: true,
      description: 'Senior School Certificate Examination (Class XII)',
      requiredForScholarship: true,
      maskedNumber: 'Roll No. 1163XXXX',
      assetImagePath: 'assets/images/class12_marksheet.jpg',
    ),
    DigiLockerDocument(
      uri: 'dl://edistrict/income_cert',
      name: 'Annual Income Certificate (2025-26)',
      issuer: 'Tahasildar Office, Revenue Department',
      issuerShort: 'e-District',
      docType: 'INCOME_CERT',
      issuedDate: DateTime(2025, 4, 12),
      isVerified: true,
      description: 'Family annual income verification — Below ₹2.50 Lakhs',
      requiredForScholarship: true,
      maskedNumber: 'REV/2025/XXXX4821',
    ),
    DigiLockerDocument(
      uri: 'dl://institute/bonafide_cert',
      name: 'College Bonafide / Enrollment Certificate',
      issuer: 'National Institute of Technology',
      issuerShort: 'NIT',
      docType: 'BONAFIDE',
      issuedDate: DateTime(2025, 7, 20),
      isVerified: false,
      description: 'Current Academic Session Bonafide Certificate',
      requiredForScholarship: false,
      maskedNumber: 'INST/2025/XXXX',
    ),
  ];
}
