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

  // New fields from API response
  final int? id;
  final String? nome;
  final String? email;
  final String? tipo;
  final double? latitude;
  final double? longitude;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.user,
    this.id,
    this.nome,
    this.email,
    this.tipo,
    this.latitude,
    this.longitude,
  });

  factory AuthResult.success({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? user,
    int? id,
    String? nome,
    String? email,
    String? tipo,
    double? latitude,
    double? longitude,
  }) {
    return AuthResult(
      success: true,
      message: 'Login realizado com sucesso.',
      token: token,
      refreshToken: refreshToken,
      user: user,
      id: id,
      nome: nome,
      email: email,
      tipo: tipo,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

class AuthService {
  AuthService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'http://192.168.15.133:8080';
  static const String _loginPath = '/auth/login';

  final String _baseUrl;

  Uri get _loginUri => Uri.parse('$_baseUrl$_loginPath');

  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Preencha todos os campos para continuar.');
    }

    try {
      final body = jsonEncode({'email': email, 'password': password});

      debugPrint('=== LOGIN REQUEST ===');
      debugPrint('URL: $_loginUri');
      debugPrint('BODY: $body');

      final response = await http
          .post(
            _loginUri,
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
      debugPrint('=== LOGIN ERROR ===');
      debugPrint('Error: $e');

      return AuthResult.failure('Erro inesperado. Tente novamente.');
    }
  }

  AuthResult _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    debugPrint('=== LOGIN RESPONSE ===');
    debugPrint('STATUS CODE: $statusCode');
    debugPrint('BODY: $body');

    if (statusCode == 200 || statusCode == 201) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (token == null || token.isEmpty) {
        return AuthResult.failure(
          'Resposta do servidor nao contem token de autenticacao.',
        );
      }

      // Extract new API fields
      final id = data['id'] as int?;
      final nome = data['nome'] as String?;
      final email = data['email'] as String?;
      final tipo = data['tipo'] as String?;
      final latitude = (data['latitude'] as num?)?.toDouble();
      final longitude = (data['longitude'] as num?)?.toDouble();

      return AuthResult.success(
        token: token,
        refreshToken: refreshToken,
        user: data,
        id: id,
        nome: nome,
        email: email,
        tipo: tipo,
        latitude: latitude,
        longitude: longitude,
      );
    }

    if (statusCode == 400) {
      return AuthResult.failure(
        'Dados de login invalidos. Verifique e tente novamente.',
      );
    }

    if (statusCode == 401) {
      return AuthResult.failure('E-mail ou senha incorretos.');
    }

    if (statusCode == 403) {
      return AuthResult.failure('Acesso negado. Contate o administrador.');
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
