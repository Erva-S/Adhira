import 'dart:typed_data';

/// Integration status of an external government gateway.
enum IntegrationStatus {
  mockDemo('Demo Mode (Simulated Response)'),
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
  final String docType;
  final DateTime? issuedDate;

  const DigiLockerDocument({
    required this.uri,
    required this.name,
    required this.issuer,
    required this.docType,
    this.issuedDate,
  });
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

/// Abstract DigiLocker service boundary.
///
/// Follows Part 14: Clean service interface with connect(), disconnect(),
/// getAvailableDocuments(), and importDocument().
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
}

/// Simulated DigiLocker service for prototype & demonstration.
/// Clearly identified as Demo Mode (never claims to be live government API).
class MockDigiLockerService implements DigiLockerService {
  bool _connected = false;

  @override
  IntegrationStatus get status => IntegrationStatus.readyForCredentials;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> connect() async {
    // Simulate OAuth delay
    await Future.delayed(const Duration(milliseconds: 800));
    _connected = true;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Future<List<DigiLockerDocument>> getAvailableDocuments() async {
    if (!_connected) {
      await connect();
    }
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      DigiLockerDocument(
        uri: 'dl://uidai/aadhaar_card',
        name: 'Aadhaar Card',
        issuer: 'UIDAI',
        docType: 'ADHAR',
        issuedDate: DateTime(2021, 5, 10),
      ),
      DigiLockerDocument(
        uri: 'dl://edistrict/st_caste_cert',
        name: 'ST Community Certificate',
        issuer: 'Revenue Department, Govt of Odisha',
        docType: 'CASTE_ST',
        issuedDate: DateTime(2023, 7, 18),
      ),
      DigiLockerDocument(
        uri: 'dl://cbse/class12_marksheet',
        name: 'Class 12 Passing Certificate & Marksheet',
        issuer: 'Central Board of Secondary Education (CBSE)',
        docType: 'ACADEMIC_12',
        issuedDate: DateTime(2023, 6, 5),
      ),
      DigiLockerDocument(
        uri: 'dl://edistrict/income_cert',
        name: 'Annual Income Certificate (2025-26)',
        issuer: 'Tahasildar Baripada',
        docType: 'INCOME_CERT',
        issuedDate: DateTime(2025, 4, 12),
      ),
    ];
  }

  @override
  Future<DigiLockerDocumentData?> importDocument(String docUri, String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulated dummy PDF binary bytes
    final dummyBytes = Uint8List.fromList(
      'MoTA DigiLocker Verified Document Payload [$docUri] for $userId'.codeUnits,
    );

    return DigiLockerDocumentData(
      uri: docUri,
      name: docUri.split('/').last.replaceAll('_', ' ').toUpperCase(),
      mimeType: 'application/pdf',
      bytes: dummyBytes,
    );
  }
}
