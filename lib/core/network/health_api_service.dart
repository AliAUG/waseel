import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/network/backend_endpoints.dart';

class HealthApiService {
  HealthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Returns JSON body on success; `null` if unreachable or non-2xx.
  Future<Map<String, dynamic>?> fetchHealth() async {
    try {
      return await _client.get(BackendEndpoints.health);
    } on ApiException {
      return null;
    }
  }
}
