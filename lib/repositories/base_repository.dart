/// Base class for repository error results.
class RepositoryException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic cause;

  const RepositoryException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'RepositoryException: $message (code: $statusCode)';
}

/// Base class for repositories providing standard exception handling.
abstract class BaseRepository {
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on RepositoryException {
      rethrow;
    } catch (e) {
      throw RepositoryException(
        'An unexpected error occurred while communicating with the data service.',
        cause: e,
      );
    }
  }
}
