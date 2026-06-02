class UserEntity {
  final int? id;
  final String nome;
  final String email;
  final String password;
  final String tipo;
  final String? telefone;
  final String? cpfCnpj;
  final String? dataNascimento;
  final String? rg;
  final String? nomeMae;
  final String? selfieDocumento;

  final String? endereco;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;

  final String? cnhNumero;
  final String? cnhCategoria;
  final String? cnhValidade;
  final String? cnhFrente;
  final String? cnhVerso;

  final String? tipoVeiculo;
  final String? marcaModelo;
  final String? anoVeiculo;
  final String? placa;

  final String? banco;
  final String? agencia;
  final String? conta;
  final String? chavePix;
  final String? cpfTitularConta;

  final String? regiaoAtuacao;
  final String? horariosDisponiveis;
  final String? possuiMei;
  final String? meiCnpj;
  final String? meiNomeEmpresa;

  final double? latitude;
  final double? longitude;

  const UserEntity({
    this.id,
    required this.nome,
    required this.email,
    required this.password,
    required this.tipo,
    this.telefone,
    this.cpfCnpj,
    this.dataNascimento,
    this.rg,
    this.nomeMae,
    this.selfieDocumento,
    this.endereco,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.cnhNumero,
    this.cnhCategoria,
    this.cnhValidade,
    this.cnhFrente,
    this.cnhVerso,
    this.tipoVeiculo,
    this.marcaModelo,
    this.anoVeiculo,
    this.placa,
    this.banco,
    this.agencia,
    this.conta,
    this.chavePix,
    this.cpfTitularConta,
    this.regiaoAtuacao,
    this.horariosDisponiveis,
    this.possuiMei,
    this.meiCnpj,
    this.meiNomeEmpresa,
    this.latitude,
    this.longitude,
  });
}
