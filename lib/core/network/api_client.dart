import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/network/backend_config.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) {
    return _send(
      method: 'GET',
      path: path,
      token: token,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      token: token,
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('${BackendConfig.baseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final payload = body == null ? null : jsonEncode(body);

    late final http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _http
              .get(uri, headers: headers)
              .timeout(BackendConfig.requestTimeout);
          break;
        case 'POST':
          response = await _http
              .post(uri, headers: headers, body: payload)
              .timeout(BackendConfig.requestTimeout);
          break;
        case 'PUT':
          response = await _http
              .put(uri, headers: headers, body: payload)
              .timeout(BackendConfig.requestTimeout);
          break;
        case 'PATCH':
          response = await _http
              .patch(uri, headers: headers, body: payload)
              .timeout(BackendConfig.requestTimeout);
          break;
        case 'DELETE':
          response = await _http
              .delete(uri, headers: headers, body: payload)
              .timeout(BackendConfig.requestTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Network request failed — could not reach $uri',
        details: e,
      );
    }

    Map<String, dynamic> jsonBody;
    try {
      jsonBody = response.body.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(response.body) as Map<String, dynamic>);
    } on FormatException {
      final snippet = response.body.length > 80
          ? '${response.body.substring(0, 80)}…'
          : response.body;
      throw ApiException(
        'Server returned non-JSON (${response.statusCode}). '
        'Is the API running at the correct URL? $snippet',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    throw ApiException(
      (jsonBody['message'] ?? 'Request failed').toString(),
      statusCode: response.statusCode,
      details: jsonBody['errors'],
    );
  }
}
