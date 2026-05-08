import '../entities/restaurante_entity.dart';

class RestauranteModel extends RestauranteEntity {
  const RestauranteModel({
    super.id,
    required super.nome,
    required super.endereco,
    super.cpfCnpj,
    super.fotoUrl,
    super.numero,
    super.bairro,
    super.cidade,
    super.estado,
    super.cep,
    super.latitude,
    super.longitude,
    super.createdAt,
    super.aprovado,
    super.taxaEntrega,
  });

  factory RestauranteModel.fromJson(Map<String, dynamic> json) {
    return RestauranteModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      endereco: json['endereco'] ?? '',
      cpfCnpj: json['cpfCnpj'],
      fotoUrl: json['fotoUrl'],
      numero: json['numero'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      aprovado: json['aprovado'] ?? false,
      taxaEntrega: json['taxaEntrega'] != null
          ? (json['taxaEntrega'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'endereco': endereco,
      'cpfCnpj': cpfCnpj,
      'fotoUrl': fotoUrl,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt?.toIso8601String(),
      'aprovado': aprovado,
      'taxaEntrega': taxaEntrega,
    };
  }

  @override
  String toString() {
    return 'RestauranteModel(id: $id, nome: $nome, cidade: $cidade)';
  }
}
