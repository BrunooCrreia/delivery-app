import '../core/entities/agendamento_entity.dart';
import '../core/entities/vagas_entity.dart';
import '../utils/http_client.dart';
import 'address_service.dart';
import 'agendamento_service.dart';
import 'vagas_service.dart';

/// API Service for authenticated endpoints
class ApiService {
  ApiService({HttpClient? httpClient})
    : _vagasService = VagasService(httpClient: httpClient),
      _agendamentoService = AgendamentoService(httpClient: httpClient),
      _addressService = AddressService(httpClient: httpClient);

  final VagasService _vagasService;
  final AgendamentoService _agendamentoService;
  final AddressService _addressService;

  /// GET /vagas
  Future<List<VagaEntity>> getVagas() => _vagasService.getVagas();

  /// GET /vagas/:id
  Future<VagaEntity> getVagaById(int id) => _vagasService.getVagaById(id);

  /// GET /agendamentos
  Future<List<AgendamentoEntity>> getAgendamentos() =>
      _agendamentoService.getAgendamentos();

  /// GET /agendamentos/:id
  Future<AgendamentoEntity> getAgendamentoById(int id) =>
      _agendamentoService.getAgendamentoById(id);

  /// GET /address/:cep
  Future<Map<String, dynamic>> getAddressByCep(String cep) =>
      _addressService.getAddressByCep(cep);
}
