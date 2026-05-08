import 'user_entity.dart';
import 'vagas_entity.dart';

class AgendamentoEntity {
  final int? id;
  final UserEntity? motoboy;
  final VagaEntity? vaga;
  final String status;

  const AgendamentoEntity({
    this.id,
    this.motoboy,
    this.vaga,
    required this.status,
  });
}
