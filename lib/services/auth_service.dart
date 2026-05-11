import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final Map<String, dynamic>? user;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.user,
  });

  factory AuthResult.success({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) {
    return AuthResult(
      success: true,
      message: 'Operacao realizada com sucesso.',
      token: token,
      refreshToken: refreshToken,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

class AuthService {
  AuthService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl,
      _client = client ?? http.Client();

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.15.133:8080',
  );
  static const String _loginPath = '/auth/login';
  static const String _registerPath = '/auth/register';

  final String _baseUrl;
  final http.Client _client;

  // ── Login ────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Preencha todos os campos para continuar.');
    }

    try {
      final body = jsonEncode({'email': email, 'password': password});

      if (kDebugMode) {
        debugPrint('=== LOGIN REQUEST ===');
        debugPrint('URL: $_baseUrl$_loginPath');
        debugPrint('BODY: $body');
      }

      final response = await _client
          .post(
            Uri.parse('$_baseUrl$_loginPath'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      return _parseResponse(response);
    } on SocketException {
      return AuthResult.failure(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } on TimeoutException {
      return AuthResult.failure('Tempo de conexao esgotado. Tente novamente.');
    } on FormatException {
      return AuthResult.failure(
        'Resposta invalida do servidor. Tente novamente mais tarde.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== LOGIN ERROR ===');
        debugPrint('Error: $e');
      }
      return AuthResult.failure('Erro inesperado. Tente novamente.');
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────

  /// Registra um novo usuario (MOTOBOY ou RESTAURANTE).
  /// O [data] deve conter todos os campos exigidos pela API para o tipo informado.
  Future<AuthResult> register(Map<String, dynamic> data) async {
    try {
      final body = jsonEncode(data);

      if (kDebugMode) {
        debugPrint('=== REGISTER REQUEST ===');
        debugPrint('URL: $_baseUrl$_registerPath');
        debugPrint('BODY: $body');
      }

      final response = await _client
          .post(
            Uri.parse('$_baseUrl$_registerPath'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('=== REGISTER RESPONSE ===');
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
      }

      return _parseResponse(response);
    } on SocketException {
      return AuthResult.failure(
        'Sem conexao com a internet. Verifique sua rede.',
      );
    } on TimeoutException {
      return AuthResult.failure('Tempo de conexao esgotado. Tente novamente.');
    } on FormatException {
      return AuthResult.failure(
        'Resposta invalida do servidor. Tente novamente mais tarde.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== REGISTER ERROR ===');
        debugPrint('Error: $e');
      }
      return AuthResult.failure('Erro inesperado. Tente novamente.');
    }
  }

  // ── Parse ─────────────────────────────────────────────────────────────────

  AuthResult _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (kDebugMode) {
      debugPrint('STATUS CODE: $statusCode');
      debugPrint('BODY: $body');
    }

    if (statusCode == 200 || statusCode == 201) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (token == null || token.isEmpty) {
        if (statusCode == 201) {
          return AuthResult(
            success: true,
            message:
                'Cadastro realizado com sucesso. Faca login para continuar.',
            user: data,
          );
        }
        return AuthResult.failure(
          'Resposta do servidor nao contem token de autenticacao.',
        );
      }

      return AuthResult.success(
        token: token,
        refreshToken: refreshToken,
        user: data,
      );
    }

    if (statusCode == 400) {
      return AuthResult.failure(
        'Dados invalidos. Verifique as informacoes e tente novamente.',
      );
    }

    if (statusCode == 401) {
      return AuthResult.failure('E-mail ou senha incorretos.');
    }

    if (statusCode == 403) {
      return AuthResult.failure('Acesso negado. Contate o administrador.');
    }

    if (statusCode == 409) {
      return AuthResult.failure('E-mail ja cadastrado. Tente fazer login.');
    }

    if (statusCode >= 500) {
      return AuthResult.failure(
        'Erro no servidor. Tente novamente mais tarde.',
      );
    }

    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final message =
          data['message'] as String? ??
          'Erro de autenticacao (${response.statusCode}).';
      return AuthResult.failure(message);
    } catch (_) {
      return AuthResult.failure(
        'Erro de autenticacao (${response.statusCode}).',
      );
    }
  }
}
