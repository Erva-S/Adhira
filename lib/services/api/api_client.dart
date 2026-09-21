/// Abstract API client for making HTTP requests.
/// Will be replaced with actual HTTP implementation (e.g., dio, http) later.
abstract class ApiClient {
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams});
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body});
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body});
  Future<void> delete(String endpoint);
}

/// Mock API client that returns demo data.
class MockApiClient implements ApiClient {
  @override
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate latency
    return {'status': 'ok', 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'status': 'ok', 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'status': 'ok', 'data': {}};
  }

  @override
  Future<void> delete(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
