class RestauranteEntity {
  final int? id;
  final String nome;
  final String endereco;
  final String? cpfCnpj;
  final String? fotoUrl;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final bool aprovado;
  final double taxaEntrega;

  const RestauranteEntity({
    this.id,
    required this.nome,
    required this.endereco,
    this.cpfCnpj,
    this.fotoUrl,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.aprovado = false,
    this.taxaEntrega = 0.0,
  });
}
