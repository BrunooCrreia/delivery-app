import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:projeto_perguntas/utils/http_client.dart';

class AddressService {
  AddressService({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

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
