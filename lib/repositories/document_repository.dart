import 'dart:typed_data';
import '../../core/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../../services/database/relational_data_store.dart';
import '../../services/storage/document_storage_service.dart';
import 'base_repository.dart';

abstract class DocumentRepository {
  Future<List<Document>> getDocumentsForUser(String userId);
  Future<List<Document>> getReusableVerifiedDocuments(String userId);
  Future<Document> uploadDocument({
    required String userId,
    required String name,
    required DocumentCategory category,
    String? documentType,
    required String fileName,
    required Uint8List bytes,
  });
  Future<List<ApplicationDocument>> getDocumentsForApplication(String applicationId);
}

class AppDocumentRepository extends BaseRepository implements DocumentRepository {
  final RelationalDataStore _dataStore;
  final DocumentStorageService _storageService;

  AppDocumentRepository({
    RelationalDataStore? dataStore,
    DocumentStorageService? storageService,
  })  : _dataStore = dataStore ?? RelationalDataStore(),
        _storageService = storageService ?? LocalDocumentStorageService();

  @override
  Future<List<Document>> getDocumentsForUser(String userId) async {
    return safeCall(() async {
      return _dataStore.getDocumentsForUser(userId);
    });
  }

  @override
  Future<List<Document>> getReusableVerifiedDocuments(String userId) async {
    return safeCall(() async {
      return _dataStore.getVerifiedDocumentsForUser(userId);
    });
  }

  @override
  Future<Document> uploadDocument({
    required String userId,
    required String name,
    required DocumentCategory category,
    String? documentType,
    required String fileName,
    required Uint8List bytes,
  }) async {
    return safeCall(() async {
      final docId = 'doc-${DateTime.now().millisecondsSinceEpoch}';
      final uploadRes = await _storageService.uploadUserDocument(
        userId: userId,
        documentId: docId,
        fileName: fileName,
        bytes: bytes,
      );

      final newDoc = Document(
        id: docId,
        userId: userId,
        name: name,
        documentType: documentType ?? name,
        category: category,
        status: DocumentStatus.uploaded,
        storagePath: uploadRes.storagePath,
        fileUrl: uploadRes.secureUrl,
        fileName: fileName,
        fileSizeBytes: bytes.length,
        uploadedAt: DateTime.now(),
      );

      return _dataStore.addDocument(newDoc);
    });
  }

  @override
  Future<List<ApplicationDocument>> getDocumentsForApplication(String applicationId) async {
    return safeCall(() async {
      return _dataStore.getApplicationDocuments(applicationId);
    });
  }
}
