import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:projeto_perguntas/core/entities/vagas_entity.dart';
import 'package:projeto_perguntas/core/models/vagas_model.dart';
import 'package:projeto_perguntas/utils/http_client.dart';

class VagasService {
  VagasService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

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
}
