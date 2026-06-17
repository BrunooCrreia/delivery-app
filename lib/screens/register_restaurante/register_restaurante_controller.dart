import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/screens/widgets/register_address_step.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/utils/input_formatters.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/services/cep_service.dart';

class RegisterRestauranteController extends ChangeNotifier
    implements IAddressStepController {
  RegisterRestauranteController({CepService? cepService})
      : _cepService = cepService ?? CepService();

  final CepService _cepService;

  final PageController pageController = PageController();
  int currentPage = 0;

  // ── Step 1 — Conta ────────────────────────────────────────────────────────
  final formKey1 = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Step 2 — Dados do Estabelecimento ────────────────────────────────────
  final formKey2 = GlobalKey<FormState>();
  final telefoneMask = AppFormatters.telefone();
  final cnpjMask = AppFormatters.cnpj();
  final razaoSocialController = TextEditingController();
  final cnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  String? tipoNegocioSelecionado;
  final List<String> tiposNegocio = [
    'Restaurante',
    'Lanchonete',
    'Pizzaria',
    'Farmácia',
    'Mercado',
    'Pet Shop',
    'Padaria',
    'Outro',
  ];

  // ── Step 3 — Responsável ─────────────────────────────────────────────────
  final formKey3 = GlobalKey<FormState>();
  final nomeResponsavelController = TextEditingController();
  final cpfResponsavelController = TextEditingController();
  final cpfResponsavelMask = AppFormatters.cpf();
  String? cargoSelecionado;
  final List<String> cargos = ['Dono', 'Gerente', 'Supervisor', 'Outro'];

  // ── Step 4 — Endereço ────────────────────────────────────────────────────
  final formKey4 = GlobalKey<FormState>();
  @override
  GlobalKey<FormState> get addressFormKey => formKey4;

  @override
  final cepController = TextEditingController();
  @override
  final enderecoController = TextEditingController();
  @override
  final numeroController = TextEditingController();
  @override
  final complementoController = TextEditingController();
  @override
  final bairroController = TextEditingController();
  @override
  final cidadeController = TextEditingController();
  @override
  final estadoController = TextEditingController();
  @override
  bool isCepLoading = false;
  @override
  bool highlightNumeroField = false;
  Timer? _cepDebounce;
  String _lastFetchedCep = '';
  int _cepRequestId = 0;
  int _numeroBlinkRequestId = 0;

  // ── Step 5 — Operacional ─────────────────────────────────────────────────
  final formKey5 = GlobalKey<FormState>();
  static const allDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const allVeiculos = ['Moto', 'Carro', 'Bicicleta'];
  Set<String> diasSelecionados = {};
  TimeOfDay? horarioAbertura;
  TimeOfDay? horarioFechamento;
  double raioEntregaKm = 5.0;
  Set<String> veiculosSelecionados = {};


  // ── General ──────────────────────────────────────────────────────────────
  bool isLoading = false;
  String errorMessage = '';

  // ── Navigation ────────────────────────────────────────────────────────────

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  @override
  void nextPage(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return;
    errorMessage = '';
    notifyListeners();
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void prevPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ── Step 2 setters ────────────────────────────────────────────────────────

  void setTipoNegocio(String? value) {
    tipoNegocioSelecionado = value;
    notifyListeners();
  }

  // ── Step 3 setters ────────────────────────────────────────────────────────

  void setCargo(String? value) {
    cargoSelecionado = value;
    notifyListeners();
  }

  // ── Step 4 — CEP ──────────────────────────────────────────────────────────

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isNullOrEmpty(dynamic value) =>
      value == null || value.toString().trim().isEmpty;

  bool _isInvalidCepPayload(Map<String, dynamic> data) {
    return _isNullOrEmpty(data['logradouro']) &&
        _isNullOrEmpty(data['bairro']) &&
        _isNullOrEmpty(data['localidade']) &&
        _isNullOrEmpty(data['uf']);
  }

  Future<void> _blinkNumeroField() async {
    final blinkId = ++_numeroBlinkRequestId;
    for (var i = 0; i < 4; i++) {
      if (blinkId != _numeroBlinkRequestId) return;
      highlightNumeroField = i.isEven;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 170));
    }
    if (blinkId != _numeroBlinkRequestId) return;
    highlightNumeroField = false;
    notifyListeners();
  }

  @override
  void onCepChanged(String value, BuildContext context) {
    final cep = _digitsOnly(value);
    _cepDebounce?.cancel();
    if (cep.length != 8) {
      _cepRequestId++;
      _lastFetchedCep = '';
      if (isCepLoading) {
        isCepLoading = false;
        notifyListeners();
      }
      return;
    }
    if (_lastFetchedCep == cep) return;
    _cepDebounce = Timer(
      const Duration(milliseconds: 450),
      () => fillAddressByCep(cep, context),
    );
  }

  Future<void> fillAddressByCep(String cep, BuildContext context) async {
    final requestId = ++_cepRequestId;
    isCepLoading = true;
    notifyListeners();
    try {
      final data = await _cepService.fetchAddress(cep);
      if (requestId != _cepRequestId) return;
      if (_isInvalidCepPayload(data)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.cepInvalido),
            ),
          );
        }
        _lastFetchedCep = '';
        return;
      }
      enderecoController.text = (data['logradouro'] as String? ?? '').trim();
      bairroController.text = (data['bairro'] as String? ?? '').trim();
      cidadeController.text = (data['localidade'] as String? ?? '').trim();
      estadoController.text = (data['uf'] as String? ?? '').trim();
      final cepFormatado = (data['cep'] as String? ?? '').trim();
      if (cepFormatado.isNotEmpty) cepController.text = cepFormatado;
      _lastFetchedCep = cep;
      unawaited(_blinkNumeroField());
      notifyListeners();
    } catch (_) {
      if (requestId != _cepRequestId) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.erroBuscarCep),
          ),
        );
      }
    } finally {
      if (requestId == _cepRequestId) {
        isCepLoading = false;
        notifyListeners();
      }
    }
  }

  // ── Step 5 setters ────────────────────────────────────────────────────────

  void toggleDia(String dia) {
    if (diasSelecionados.contains(dia)) {
      diasSelecionados = Set.from(diasSelecionados)..remove(dia);
    } else {
      diasSelecionados = Set.from(diasSelecionados)..add(dia);
    }
    notifyListeners();
  }

  void toggleVeiculo(String veiculo) {
    if (veiculosSelecionados.contains(veiculo)) {
      veiculosSelecionados = Set.from(veiculosSelecionados)..remove(veiculo);
    } else {
      veiculosSelecionados = Set.from(veiculosSelecionados)..add(veiculo);
    }
    notifyListeners();
  }

  void setRaioEntrega(double value) {
    raioEntregaKm = value;
    notifyListeners();
  }

  Future<void> selectHorarioAbertura(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: horarioAbertura ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (time != null) {
      horarioAbertura = time;
      notifyListeners();
    }
  }

  Future<void> selectHorarioFechamento(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: horarioFechamento ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (time != null) {
      horarioFechamento = time;
      notifyListeners();
    }
  }

  bool validateStep5(BuildContext context) {
    if (diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selecioneDias)),
      );
      return false;
    }
    if (horarioAbertura == null || horarioFechamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.informeHorario)),
      );
      return false;
    }
    if (veiculosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selecioneVeiculo)),
      );
      return false;
    }
    return true;
  }

  void nextStep5(BuildContext context) {
    if (!validateStep5(context)) return;
    handleRegister(context);
  }

  // ── Register ──────────────────────────────────────────────────────────────

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> handleRegister(BuildContext context) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final authService = AuthService();
    final result = await authService.register({
      // Step 1
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'tipo': 'RESTAURANTE',
      // Step 2
      'nome': razaoSocialController.text.trim(),
      'razaoSocial': razaoSocialController.text.trim(),
      'cpfCnpj': _digitsOnly(cnpjController.text),
      'tipoNegocio': tipoNegocioSelecionado ?? '',
      'telefone': _digitsOnly(telefoneController.text),
      // Step 3
      'nomeResponsavel': nomeResponsavelController.text.trim(),
      'cpfResponsavel': _digitsOnly(cpfResponsavelController.text),
      'cargoResponsavel': cargoSelecionado ?? '',
      // Step 4
      'endereco': enderecoController.text.trim(),
      'numero': numeroController.text.trim(),
      'complemento': complementoController.text.trim(),
      'bairro': bairroController.text.trim(),
      'cidade': cidadeController.text.trim(),
      'estado': estadoController.text.trim(),
      'cep': _digitsOnly(cepController.text),
      'latitude': 0.0,
      'longitude': 0.0,
      // Step 5
      'diasFuncionamento': diasSelecionados.join(','),
      'horarioAbertura': _formatTimeOfDay(horarioAbertura),
      'horarioFechamento': _formatTimeOfDay(horarioFechamento),
      'raioEntregaKm': raioEntregaKm,
      'veiculosAceitos': veiculosSelecionados.join(','),
    });

    isLoading = false;
    errorMessage = result.success ? '' : result.message;
    notifyListeners();

    if (!result.success || !context.mounted) return;

    if (result.token != null && result.token!.isNotEmpty) {
      await AuthStorage().saveToken(result.token!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.restauranteCadastrado)),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.cadastroConcluidoLogin)),
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _cepDebounce?.cancel();
    pageController.dispose();
    // Step 1
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    // Step 2
    razaoSocialController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    // Step 3
    nomeResponsavelController.dispose();
    cpfResponsavelController.dispose();
    // Step 4
    cepController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    super.dispose();
  }
}
