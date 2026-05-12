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
  final Map<String, dynamic>? body; // ✅ alteração 5: body completo

  const HttpException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'HttpException: $message (status: $statusCode)';
}

/// Cliente HTTP base com autenticação Bearer automática.
///
/// Pode ser configurado via parâmetros opcionais no construtor:
/// - [baseUrl]: URL base da API. Se não informado, usa a variável de ambiente
///   `API_BASE_URL` definida via `--dart-define`. Caso a variável também não
///   esteja definida, usa o endereço local de desenvolvimento como fallback.
/// - [authStorage]: responsável por ler o token salvo. Se não informado,
///   cria uma instância padrão — útil para injetar um mock nos testes.
/// - [client]: cliente HTTP do pacote `http`. Se não informado, cria uma
///   instância padrão — útil para injetar um mock nos testes.
/// Base HTTP client that automatically adds Bearer token authentication
class HttpClient {
  HttpClient({String? baseUrl, AuthStorage? authStorage, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl,
      _authStorage = authStorage ?? AuthStorage(),
      _client = client ?? http.Client();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.15.133:8080',
  );

  final String _baseUrl;
  final AuthStorage _authStorage;
  final http.Client _client;

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final safe = Map<String, String>.from(headers);
    if (safe.containsKey('Authorization')) {
      safe['Authorization'] = 'Bearer ***';
    }
    return safe;
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
  Future<http.Response> get(String path, {bool requireAuth = true}) async {
    try {
      final headers = await getHeaders(requireAuth: requireAuth);
      final url = _buildUri(path);

      if (kDebugMode) {
        debugPrint('=== HTTP GET ===');
        debugPrint('URL: $url');
        debugPrint('HEADERS: ${_sanitizeHeaders(headers)}');
      }

      final response = await _client
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on HttpException {
      rethrow;
    } on TimeoutException {
      throw const HttpException('Tempo de conexao esgotado. Tente novamente.');
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== HTTP GET ERROR ===');
        debugPrint('Error: $e');
      }
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

      if (kDebugMode) {
        debugPrint('=== HTTP POST ===');
        debugPrint('URL: $url');
        debugPrint('HEADERS: ${_sanitizeHeaders(headers)}');
        debugPrint('BODY: $encodedBody');
      }

      final response = await _client
          .post(url, headers: headers, body: encodedBody)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on HttpException {
      rethrow;
    } on TimeoutException {
      throw const HttpException('Tempo de conexao esgotado. Tente novamente.');
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== HTTP POST ERROR ===');
        debugPrint('Error: $e');
      }
      throw HttpException('Erro inesperado. Tente novamente.');
    }
  }

  /// PUT request with automatic Bearer token
  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requireAuth: requireAuth);
      final url = _buildUri(path);
      final encodedBody = body != null ? jsonEncode(body) : null;

      if (kDebugMode) {
        debugPrint('=== HTTP PUT ===');
        debugPrint('URL: $url');
        debugPrint('HEADERS: ${_sanitizeHeaders(headers)}');
        debugPrint('BODY: $encodedBody');
      }

      final response = await _client
          .put(url, headers: headers, body: encodedBody)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on HttpException {
      rethrow;
    } on TimeoutException {
      throw const HttpException('Tempo de conexao esgotado. Tente novamente.');
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== HTTP PUT ERROR ===');
        debugPrint('Error: $e');
      }
      throw HttpException('Erro inesperado. Tente novamente.');
    }
  }

  /// DELETE request with automatic Bearer token
  Future<http.Response> delete(String path, {bool requireAuth = true}) async {
    try {
      final headers = await getHeaders(requireAuth: requireAuth);
      final url = _buildUri(path);

      if (kDebugMode) {
        debugPrint('=== HTTP DELETE ===');
        debugPrint('URL: $url');
        debugPrint('HEADERS: ${_sanitizeHeaders(headers)}');
      }

      final response = await _client
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      _handleError(response);
      return response;
    } on TokenException {
      rethrow;
    } on HttpException {
      rethrow;
    } on TimeoutException {
      throw const HttpException('Tempo de conexao esgotado. Tente novamente.');
    } on SocketException {
      throw const HttpException(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== HTTP DELETE ERROR ===');
        debugPrint('Error: $e');
      }
      throw HttpException('Erro inesperado. Tente novamente.');
    }
  }

  /// Handles HTTP errors, including token expiration/invalid token
  void _handleError(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == 401) {
      final body = _tryDecodeBody(response.body);
      final message =
          body['message']?.toString() ??
          'Token expirado ou invalido. Faca login novamente.';
      throw TokenException(message);
    }

    if (statusCode == 403) {
      throw const TokenException('Acesso negado. Token invalido ou revogado.');
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
          body['message']?.toString() ?? 'Erro na requisicao ($statusCode)';
      throw HttpException(
        message,
        statusCode: statusCode,
        body: body,
      ); // ✅ alteração 5
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
