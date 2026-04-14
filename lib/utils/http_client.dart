import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_storage.dart';

/// Custom exception for token-related errors
class TokenException implements Exception {
  final String message;
  const TokenException(this.message);

  @override
  String toString() => 'TokenException: $message';
}

/// Custom exception for HTTP errors
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  const HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $message (status: $statusCode)';
}

/// Base HTTP client that automatically adds Bearer token authentication
class HttpClient {
  HttpClient({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'http://192.168.15.133:8080';
  final String _baseUrl;

  final http.Client _client = http.Client();
  final AuthStorage _authStorage = AuthStorage();

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
  }

  /// Returns headers with automatic Bearer token injection
  Future<Map<String, String>> getHeaders({bool requireAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await _authStorage.getToken();
      if (token == null || token.isEmpty) {
        throw const TokenException(
          'Token nao encontrado. Faca login novamente.',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// GET request with automatic Bearer token
  Future<http.Response> get(
    String path, {
    bool requireAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requireAuth: requireAuth);
      final url = _buildUri(path);

      debugPrint('=== HTTP GET ===');
      debugPrint('URL: $url');
      debugPrint('HEADERS: $headers');

      final response = await _client.get(url, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on TimeoutException {
      throw const HttpException(
        'Tempo de conexao esgotado. Tente novamente.',
      );
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      debugPrint('=== HTTP GET ERROR ===');
      debugPrint('Error: $e');
      throw HttpException('Erro inesperado. Tente novamente.');
    }
  }

  /// POST request with automatic Bearer token
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requireAuth: requireAuth);
      final url = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;

      debugPrint('=== HTTP POST ===');
      debugPrint('URL: $url');
      debugPrint('HEADERS: $headers');
      debugPrint('BODY: $encodedBody');

      final response = await _client
          .post(url, headers: headers, body: encodedBody)
          .timeout(const Duration(seconds: 15));

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on TimeoutException {
      throw const HttpException(
        'Tempo de conexao esgotado. Tente novamente.',
      );
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      debugPrint('=== HTTP POST ERROR ===');
      debugPrint('Error: $e');
      throw HttpException('Erro inesperado. Tente novamente.');
    }
  }

  /// Handles HTTP errors, including token expiration/invalid token
  void _handleError(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == 401) {
      final body = _tryDecodeBody(response.body);
      final message = body['message']?.toString() ??
          'Token expirado ou invalido. Faca login novamente.';
      throw TokenException(message);
    }

    if (statusCode == 403) {
      throw const TokenException(
        'Acesso negado. Token invalido ou revogado.',
      );
    }

    if (statusCode >= 500) {
      throw HttpException(
        'Erro no servidor. Tente novamente mais tarde.',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 400) {
      final body = _tryDecodeBody(response.body);
      final message =
          body['message']?.toString() ??
          'Erro na requisicao ($statusCode)';
      throw HttpException(message, statusCode: statusCode);
    }
  }

  Map<String, dynamic> _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
