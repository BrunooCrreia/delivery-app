import '../entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.nome,
    required super.email,
    required super.password,
    required super.tipo,
    super.latitude,
    super.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? json['senha'] ?? json['senha_hash'] ?? '',
      tipo: json['tipo'] ?? '',
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
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nome: $nome, email: $email, tipo: $tipo)';
  }
}
