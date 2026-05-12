import '../entities/agendamento_entity.dart';
import 'user_model.dart';
import 'vagas_model.dart';

class AgendamentoModel extends AgendamentoEntity {
  const AgendamentoModel({
    super.id,
    super.motoboy,
    super.vaga,
    required super.status,
  });

  /// Converte JSON da API para Model
  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    return AgendamentoModel(
      id: json['id'],
      motoboy: json['motoboy'] != null
          ? UserModel.fromJson(json['motoboy'])
          : null,
      vaga: json['vaga'] != null ? VagaModel.fromJson(json['vaga']) : null,
      status: json['status'] ?? '',
    );
  }

  /// Converte Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motoboy': motoboy != null ? (motoboy as UserModel).toJson() : null,
      'vaga': vaga != null ? (vaga as VagaModel).toJson() : null,
      'status': status,
    };
  }
}
