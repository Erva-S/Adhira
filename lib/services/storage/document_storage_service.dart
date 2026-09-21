import 'dart:typed_data';

/// Result of a document upload operation to isolated private storage.
class StorageUploadResult {
  final bool success;
  final String storagePath;
  final String? secureUrl;
  final String? errorMessage;

  const StorageUploadResult({
    required this.success,
    required this.storagePath,
    this.secureUrl,
    this.errorMessage,
  });
}

/// Abstract contract for secure, user-isolated document storage.
///
/// Follows Part 8:
/// User documents MUST be isolated by user identity:
/// `documents/{userId}/{documentId}`.
/// Private authenticated access only; never exposes private documents
/// through public unauthenticated URLs.
abstract class DocumentStorageService {
  /// Upload document bytes into the user's isolated storage folder.
  Future<StorageUploadResult> uploadUserDocument({
    required String userId,
    required String documentId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  });

  /// Generate a secure, time-limited authenticated access URL for viewing a document.
  Future<String?> getAuthenticatedUrl({
    required String userId,
    required String storagePath,
    Duration expiresIn = const Duration(minutes: 60),
  });

  /// Delete a document from isolated storage.
  Future<bool> deleteUserDocument({
    required String userId,
    required String storagePath,
  });
}

/// Local/Mock implementation of [DocumentStorageService] for offline/development mode.
/// Enforces path structure `documents/{userId}/{documentId}` and prevents unauthorized access across users.
class LocalDocumentStorageService implements DocumentStorageService {
  // In-memory store of uploaded file bytes: key is the storagePath
  final Map<String, Uint8List> _storage = {};

  @override
  Future<StorageUploadResult> uploadUserDocument({
    required String userId,
    required String documentId,
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    if (userId.isEmpty || documentId.isEmpty) {
      return const StorageUploadResult(
        success: false,
        storagePath: '',
        errorMessage: 'Invalid user ID or document ID for secure storage.',
      );
    }

    // Isolate by userId
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = 'documents/$userId/${documentId}_$sanitizedFileName';
    _storage[storagePath] = bytes;

    return StorageUploadResult(
      success: true,
      storagePath: storagePath,
      secureUrl: 'secure://$storagePath',
    );
  }

  @override
  Future<String?> getAuthenticatedUrl({
    required String userId,
    required String storagePath,
    Duration expiresIn = const Duration(minutes: 60),
  }) async {
    // Enforce user isolation: path must start with documents/{userId}/
    final expectedPrefix = 'documents/$userId/';
    if (!storagePath.startsWith(expectedPrefix)) {
      // Security violation: User attempting to access another user's document path
      return null;
    }

    if (!_storage.containsKey(storagePath)) {
      // Fallback for demo seed records
      return 'secure://$storagePath';
    }

    return 'secure://$storagePath?expires=${DateTime.now().add(expiresIn).millisecondsSinceEpoch}';
  }

  @override
  Future<bool> deleteUserDocument({
    required String userId,
    required String storagePath,
  }) async {
    final expectedPrefix = 'documents/$userId/';
    if (!storagePath.startsWith(expectedPrefix)) {
      return false; // Security rejection
    }

    _storage.remove(storagePath);
    return true;
  }
}
