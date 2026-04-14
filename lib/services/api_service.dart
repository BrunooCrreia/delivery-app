import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../utils/http_client.dart';

/// Model for a job opportunity (vaga)
class Vaga {
  final int id;
  final String titulo;
  final String descricao;
  final String? localizacao;
  final double? latitude;
  final double? longitude;
  final double? valor;
  final String? status;

  const Vaga({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.localizacao,
    this.latitude,
    this.longitude,
    this.valor,
    this.status,
  });

  factory Vaga.fromJson(Map<String, dynamic> json) {
    return Vaga(
      id: json['id'] as int? ?? 0,
      titulo: json['titulo'] as String? ?? json['nome'] as String? ?? '',
      descricao: json['descricao'] as String? ?? json['detalhes'] as String? ?? '',
      localizacao: json['localizacao'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      valor: (json['valor'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'latitude': latitude,
      'longitude': longitude,
      'valor': valor,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Vaga(id: $id, titulo: $titulo, localizacao: $localizacao)';
  }
}

/// API Service for authenticated endpoints
class ApiService {
  ApiService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  /// Fetches available jobs (vagas) - GET /vagas
  Future<List<Vaga>> getVagas() async {
    try {
      final response = await _httpClient.get('/vagas');
      final data = jsonDecode(response.body) as dynamic;

      // Handle both array and object with array property
      List<dynamic> jsonList;
      if (data is List) {
        jsonList = data;
      } else if (data is Map<String, dynamic>) {
        jsonList = data['vagas'] as List? ?? data['data'] as List? ?? [];
      } else {
        jsonList = [];
      }

      debugPrint('=== GET VAGAS ===');
      debugPrint('Total vagas encontradas: ${jsonList.length}');

      return jsonList
          .map((json) => Vaga.fromJson(json as Map<String, dynamic>))
          .toList();
    } on TokenException {
      rethrow;
    } catch (e) {
      debugPrint('=== GET VAGAS ERROR ===');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Example: GET /vagas/:id
  Future<Vaga> getVagaById(int id) async {
    final response = await _httpClient.get('/vagas/$id');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Vaga.fromJson(data);
  }
}
