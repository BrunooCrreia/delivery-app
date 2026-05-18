import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:projeto_perguntas/core/entities/agendamento_entity.dart';
import 'package:projeto_perguntas/core/models/agendamento_model.dart';
import 'package:projeto_perguntas/utils/http_client.dart';

class AgendamentoService {
  AgendamentoService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

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
}
