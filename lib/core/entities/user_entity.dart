class UserEntity {
  final int? id;
  final String nome;
  final String email;
  final String password;
  final String tipo;
  final double? latitude;
  final double? longitude;

  const UserEntity({
    this.id,
    required this.nome,
    required this.email,
    required this.password,
    required this.tipo,
    this.latitude,
    this.longitude,
  });
}
