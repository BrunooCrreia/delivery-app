import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../core/entities/vagas_entity.dart';
import '../core/entities/agendamento_entity.dart';
import '../core/models/vagas_model.dart';
import '../core/models/agendamento_model.dart';
import '../utils/http_client.dart';

/// API Service for authenticated endpoints
class ApiService {
  ApiService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  /// GET /vagas
  Future<List<VagaEntity>> getVagas() async {
    try {
      final response = await _httpClient.get('/vagas');
      final data = jsonDecode(response.body) as dynamic;

      List<dynamic> jsonList;
      if (data is List) {
        jsonList = data;
      } else if (data is Map<String, dynamic>) {
        jsonList = data['vagas'] as List? ?? data['data'] as List? ?? [];
      } else {
        jsonList = [];
      }

      if (kDebugMode) {
        debugPrint('=== GET VAGAS ===');
        debugPrint('Total vagas encontradas: ${jsonList.length}');
      }

      return jsonList
          .map((json) => VagaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on TokenException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== GET VAGAS ERROR ===');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }

  /// GET /vagas/:id
  Future<VagaEntity> getVagaById(int id) async {
    try {
      final response = await _httpClient.get('/vagas/$id');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return VagaModel.fromJson(data);
    } on TokenException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== GET VAGA BY ID ERROR ===');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }

  /// GET /agendamentos
  Future<List<AgendamentoEntity>> getAgendamentos() async {
    try {
      final response = await _httpClient.get('/agendamentos');
      final data = jsonDecode(response.body) as dynamic;

      List<dynamic> jsonList;
      if (data is List) {
        jsonList = data;
      } else if (data is Map<String, dynamic>) {
        jsonList = data['agendamentos'] as List? ?? data['data'] as List? ?? [];
      } else {
        jsonList = [];
      }

      if (kDebugMode) {
        debugPrint('=== GET AGENDAMENTOS ===');
        debugPrint('Total agendamentos: ${jsonList.length}');
      }

      return jsonList
          .map(
            (json) => AgendamentoModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on TokenException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== GET AGENDAMENTOS ERROR ===');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }

  /// GET /agendamentos/:id
  Future<AgendamentoEntity> getAgendamentoById(int id) async {
    try {
      final response = await _httpClient.get('/agendamentos/$id');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AgendamentoModel.fromJson(data);
    } on TokenException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== GET AGENDAMENTO BY ID ERROR ===');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }

  /// GET /address/:cep
  Future<Map<String, dynamic>> getAddressByCep(String cep) async {
    try {
      final response = await _httpClient.get(
        '/address/$cep',
        requireAuth: false,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on TokenException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('=== GET ADDRESS BY CEP ERROR ===');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }
}
