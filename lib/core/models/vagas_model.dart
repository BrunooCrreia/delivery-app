import '../entities/vagas_entity.dart';
import 'restaurante_model.dart';

class VagaModel extends VagaEntity {
  const VagaModel({
    super.id,
    required super.descricao,
    required super.valor,
    required super.data,
    required super.horaInicio,
    required super.horaFim,
    required super.status,
    super.latitude,
    super.longitude,
    super.restaurante,
  });

  factory VagaModel.fromJson(Map<String, dynamic> json) {
    return VagaModel(
      id: json['id'],
      descricao: json['descricao'] ?? '',
      valor: (json['valor'] as num).toDouble(),
      data: DateTime.parse(json['data']),
      horaInicio: json['horaInicio'] ?? '',
      horaFim: json['horaFim'] ?? '',
      status: json['status'] ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      restaurante: json['restaurante'] != null
          ? RestauranteModel.fromJson(json['restaurante'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String().split('T').first,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'restaurante': (restaurante as RestauranteModel?)?.toJson(),
    };
  }
}
