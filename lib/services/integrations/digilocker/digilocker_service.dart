/// Abstract DigiLocker integration service.
abstract class DigiLockerService {
  /// Initiate DigiLocker OAuth flow and return auth URL.
  Future<String> getAuthUrl();

  /// Exchange authorization code for access token.
  Future<String?> exchangeCode(String code);

  /// Fetch list of available documents from user's DigiLocker.
  Future<List<DigiLockerDocument>> fetchDocuments(String accessToken);

  /// Download a specific document.
  Future<DigiLockerDocumentData?> downloadDocument(String accessToken, String docUri);
}

/// Represents a document available in DigiLocker.
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
  final List<int> bytes;

  const DigiLockerDocumentData({
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
}

/// Mock DigiLocker service for development.
class MockDigiLockerService implements DigiLockerService {
  @override
  Future<String> getAuthUrl() async => 'https://digilocker.gov.in/mock-auth';

  @override
  Future<String?> exchangeCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_digilocker_token';
  }

  @override
  Future<List<DigiLockerDocument>> fetchDocuments(String accessToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      DigiLockerDocument(uri: 'dl://aadhaar', name: 'Aadhaar Card', issuer: 'UIDAI', docType: 'ADHAR'),
      DigiLockerDocument(uri: 'dl://class12', name: 'Class 12 Marksheet', issuer: 'CBSE', docType: 'MRKSHT'),
      DigiLockerDocument(uri: 'dl://domicile', name: 'Domicile Certificate', issuer: 'State Govt', docType: 'DOMCL'),
    ];
  }

  @override
  Future<DigiLockerDocumentData?> downloadDocument(String accessToken, String docUri) async {
    await Future.delayed(const Duration(seconds: 1));
    return null; // Stub
  }
}
