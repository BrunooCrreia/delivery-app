import '../entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.nome,
    required super.email,
    required super.password,
    required super.tipo,
    super.telefone,
    super.cpfCnpj,
    super.dataNascimento,
    super.rg,
    super.nomeContatoEmergencia,
    super.telefoneEmergencia,
    super.selfieDocumento,
    super.endereco,
    super.numero,
    super.bairro,
    super.cidade,
    super.estado,
    super.cep,
    super.cnhNumero,
    super.cnhValidade,
    super.cnhFrente,
    super.cnhVerso,
    super.tipoVeiculo,
    super.marcaModelo,
    super.anoVeiculo,
    super.placa,
    super.banco,
    super.agencia,
    super.conta,
    super.chavePix,
    super.cpfTitularConta,
    super.regiaoAtuacao,
    super.horariosDisponiveis,
    super.possuiMei,
    super.meiCnpj,
    super.meiNomeEmpresa,
    super.latitude,
    super.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) {
      if (value == null) return null;
      final parsed = value.toString().trim();
      return parsed.isEmpty ? null : parsed;
    }

    return UserModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? json['senha'] ?? json['senha_hash'] ?? '',
      tipo: json['tipo'] ?? '',
      telefone: asString(json['telefone']),
      cpfCnpj: asString(json['cpfCnpj'] ?? json['cpf']),
      dataNascimento: asString(json['dataNascimento']),
      rg: asString(json['rg']),
      nomeContatoEmergencia: asString(json['nomeContatoEmergencia']),
      telefoneEmergencia: asString(json['telefoneEmergencia']),
      selfieDocumento: asString(json['selfieDocumento']),
      endereco: asString(json['endereco']),
      numero: asString(json['numero']),
      bairro: asString(json['bairro']),
      cidade: asString(json['cidade']),
      estado: asString(json['estado']),
      cep: asString(json['cep']),
      cnhNumero: asString(json['cnhNumero']),
      cnhValidade: asString(json['cnhValidade']),
      cnhFrente: asString(json['cnhFrente']),
      cnhVerso: asString(json['cnhVerso']),
      tipoVeiculo: asString(json['tipoVeiculo']),
      marcaModelo: asString(json['marcaModelo']),
      anoVeiculo: asString(json['anoVeiculo']),
      placa: asString(json['placa']),
      banco: asString(json['banco']),
      agencia: asString(json['agencia']),
      conta: asString(json['conta']),
      chavePix: asString(json['chavePix']),
      cpfTitularConta: asString(json['cpfTitularConta']),
      regiaoAtuacao: asString(json['regiaoAtuacao']),
      horariosDisponiveis: asString(json['horariosDisponiveis']),
      possuiMei: asString(json['possuiMei']),
      meiCnpj: asString(json['meiCnpj']),
      meiNomeEmpresa: asString(json['meiNomeEmpresa']),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password': password,
      'tipo': tipo,
      'telefone': telefone,
      'cpfCnpj': cpfCnpj,
      'dataNascimento': dataNascimento,
      'rg': rg,
      'nomeContatoEmergencia': nomeContatoEmergencia,
      'telefoneEmergencia': telefoneEmergencia,
      'selfieDocumento': selfieDocumento,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'cnhNumero': cnhNumero,
      'cnhValidade': cnhValidade,
      'cnhFrente': cnhFrente,
      'cnhVerso': cnhVerso,
      'tipoVeiculo': tipoVeiculo,
      'marcaModelo': marcaModelo,
      'anoVeiculo': anoVeiculo,
      'placa': placa,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'chavePix': chavePix,
      'cpfTitularConta': cpfTitularConta,
      'regiaoAtuacao': regiaoAtuacao,
      'horariosDisponiveis': horariosDisponiveis,
      'possuiMei': possuiMei,
      'meiCnpj': meiCnpj,
      'meiNomeEmpresa': meiNomeEmpresa,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nome: $nome, email: $email, tipo: $tipo)';
  }
}
