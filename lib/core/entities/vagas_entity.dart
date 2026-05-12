import 'restaurante_entity.dart';

class VagaEntity {
  final int? id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String horaInicio;
  final String horaFim;
  final String status;
  final double? latitude;
  final double? longitude;
  final RestauranteEntity? restaurante;

  const VagaEntity({
    this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.horaInicio,
    required this.horaFim,
    required this.status,
    this.latitude,
    this.longitude,
    this.restaurante,
  });
}
