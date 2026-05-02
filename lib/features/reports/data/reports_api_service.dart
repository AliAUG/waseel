import 'package:waseel/core/network/api_client.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/network/backend_endpoints.dart';
import 'package:waseel/features/reports/models/report_category.dart';

/// Submits user reports for admin review.
///
/// **Backend contract** (suggested for admin dashboard):
/// - `POST /reports` with Bearer token
/// - Body fields below; server stores with `status: open`, `createdAt`, and exposes
///   `GET /admin/reports` (or Mongo collection `reports`) for staff UI.
class ReportsApiService {
  ReportsApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [reporterRole] / [reportedRole]: `passenger` | `driver`
  Future<void> submitReport({
    required String token,
    required String reporterRole,
    required String reportedRole,
    required ReportCategory category,
    required String description,
    String? tripOrJobId,
    String? tripType,
    String? reportedUserName,
  }) async {
    if (token.isEmpty || token == 'local-session') {
      throw ApiException('Sign in with a real account to submit a report.');
    }
    final body = <String, dynamic>{
      'reporterRole': reporterRole,
      'reportedRole': reportedRole,
      'category': category.apiValue,
      'description': description.trim(),
      if (tripOrJobId != null && tripOrJobId.isNotEmpty) 'tripOrJobId': tripOrJobId,
      if (tripType != null && tripType.isNotEmpty) 'tripType': tripType,
      if (reportedUserName != null && reportedUserName.trim().isNotEmpty)
        'reportedUserName': reportedUserName.trim(),
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _client.post(
      BackendEndpoints.reports,
      token: token,
      body: body,
    );
  }
}
