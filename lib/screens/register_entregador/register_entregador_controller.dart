import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projeto_perguntas/utils/input_formatters.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/screens/widgets/register_address_step.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/services/cep_service.dart';

class RegisterEntregadorController extends ChangeNotifier
    implements IAddressStepController {
  RegisterEntregadorController({CepService? cepService})
    : _cepService = cepService ?? CepService();

  final CepService _cepService;

  final PageController pageController = PageController();
  int currentPage = 0;

  final cpfMask = AppFormatters.cpf();
  final cnpjMask = AppFormatters.cnpj();
  final dataMask = AppFormatters.data();
  final telefoneMask = AppFormatters.telefone();

  final formKey1 = GlobalKey<FormState>();
  final nomeCompletoController = TextEditingController();
  final cpfController = TextEditingController();
  final rgController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final selfieController = TextEditingController();
  final nomeContatoEmergenciaController = TextEditingController();
  final telefoneEmergenciaController = TextEditingController();

  final formKey2 = GlobalKey<FormState>();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey3 = GlobalKey<FormState>();
  @override
  GlobalKey<FormState> get addressFormKey => formKey3;

  @override
  final enderecoController = TextEditingController();
  @override
  final numeroController = TextEditingController();
  @override
  final bairroController = TextEditingController();
  @override
  final complementoController = TextEditingController();
  @override
  final cidadeController = TextEditingController();
  @override
  final estadoController = TextEditingController();
  @override
  final cepController = TextEditingController();

  final formKey4 = GlobalKey<FormState>();
  final cnhNumeroController = TextEditingController();
  final cnhValidadeController = TextEditingController();
  final cnhFrenteController = TextEditingController();
  final cnhVersoController = TextEditingController();

  final formKey5 = GlobalKey<FormState>();
  final marcaModeloController = TextEditingController();
  final anoVeiculoController = TextEditingController();
  final placaController = TextEditingController();

  final formKey6 = GlobalKey<FormState>();
  final bancoController = TextEditingController();
  final agenciaController = TextEditingController();
  final contaController = TextEditingController();
  final chavePixController = TextEditingController();
  final cpfTitularController = TextEditingController();

  final formKey7 = GlobalKey<FormState>();
  final regiaoAtuacaoController = TextEditingController();
  final horariosDisponiveisController = TextEditingController();
  final meiCnpjController = TextEditingController();
  final meiNomeEmpresaController = TextEditingController();

  final List<String> tiposVeiculo = ['Moto', 'Bike', 'Carro'];
  final List<String> opcoesPossuiMei = ['Sim', 'Nao'];

  String? tipoVeiculoSelecionado;
  String possuiMeiSelecionado = 'Nao';

  bool leuTermos = false;
  bool aceitouTermos = false;
  bool isLoading = false;
  @override
  bool isCepLoading = false;
  @override
  bool highlightNumeroField = false;
  String errorMessage = '';
  Timer? _cepDebounce;
  String _lastFetchedCep = '';
  int _cepRequestId = 0;
  int _numeroBlinkRequestId = 0;

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setLeuTermos(bool value) {
    leuTermos = value;
    notifyListeners();
  }

  void setAceitouTermos(bool value) {
    aceitouTermos = value;
    notifyListeners();
  }

  void setTipoVeiculo(String? value) {
    tipoVeiculoSelecionado = value;
    notifyListeners();
  }

  void setPossuiMei(String? value) {
    possuiMeiSelecionado = value ?? 'Nao';
    if (possuiMeiSelecionado != 'Sim') {
      meiCnpjController.clear();
      meiNomeEmpresaController.clear();
    }
    notifyListeners();
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
  void nextPage(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) {
      return;
    }

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

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  String _formatBirthDateForApi(String value) {
    final digits = _digitsOnly(value);
    if (digits.length != 8) return value.trim();

    final day = digits.substring(0, 2);
    final month = digits.substring(2, 4);
    final year = digits.substring(4, 8);
    return '$year-$month-$day';
  }

  bool _isNullOrEmpty(dynamic value) {
    return value == null || value.toString().trim().isEmpty;
  }

  bool _isInvalidCepPayload(Map<String, dynamic> data) {
    return _isNullOrEmpty(data['logradouro']) &&
        _isNullOrEmpty(data['bairro']) &&
        _isNullOrEmpty(data['localidade']) &&
        _isNullOrEmpty(data['uf']);
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

    if (_lastFetchedCep == cep) {
      return;
    }

    _cepDebounce = Timer(const Duration(milliseconds: 450), () {
      fillAddressByCep(cep, context);
    });
  }

  Future<void> fillAddressByCep(String cep, BuildContext context) async {
    final requestId = ++_cepRequestId;

    isCepLoading = true;
    notifyListeners();

    try {
      final data = await _cepService.fetchAddress(cep);
      if (requestId != _cepRequestId) return;

      if (_isInvalidCepPayload(data)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.cepInvalido),
          ),
        );
        _lastFetchedCep = '';
        return;
      }

      enderecoController.text = (data['logradouro'] as String? ?? '').trim();
      bairroController.text = (data['bairro'] as String? ?? '').trim();
      cidadeController.text = (data['localidade'] as String? ?? '').trim();
      estadoController.text = (data['uf'] as String? ?? '').trim();

      final cepFormatado = (data['cep'] as String? ?? '').trim();
      if (cepFormatado.isNotEmpty) {
        cepController.text = cepFormatado;
      }

      _lastFetchedCep = cep;
      unawaited(_blinkNumeroField());
      notifyListeners();
    } catch (_) {
      if (requestId != _cepRequestId) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.erroBuscarCep),
        ),
      );
    } finally {
      if (requestId == _cepRequestId) {
        isCepLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> handleRegister(BuildContext context) async {
    if (!formKey7.currentState!.validate()) return;

    if (tipoVeiculoSelecionado == null || tipoVeiculoSelecionado!.isEmpty) {
      errorMessage = AppStrings.selecioneVeiculoTipo;
      notifyListeners();
      return;
    }

    if (!aceitouTermos) {
      errorMessage = AppStrings.precisaAceitarTermos;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final authService = AuthService();
    final result = await authService.register({
      'nome': nomeCompletoController.text.trim(),
      'email': emailController.text.trim(),
      'telefone': _digitsOnly(telefoneController.text.trim()),
      'password': passwordController.text,
      'tipo': 'MOTOBOY',
      'cpfCnpj': cpfController.text.trim(),
      'dataNascimento': _formatBirthDateForApi(dataNascimentoController.text),
      'rg': rgController.text.trim(),
      'nomeContatoEmergencia': nomeContatoEmergenciaController.text.trim().isEmpty
          ? null
          : nomeContatoEmergenciaController.text.trim(),
      'telefoneEmergencia': telefoneEmergenciaController.text.trim().isEmpty
          ? null
          : telefoneEmergenciaController.text.trim(),
      'selfieDocumento': selfieController.text.trim(),
      'endereco': enderecoController.text.trim(),
      'numero': numeroController.text.trim(),
      'bairro': bairroController.text.trim(),
      'cidade': cidadeController.text.trim(),
      'estado': estadoController.text.trim(),
      'cep': cepController.text.trim(),
      'cnhNumero': cnhNumeroController.text.trim(),
      'cnhValidade': _formatBirthDateForApi(cnhValidadeController.text),
      'cnhFrente': cnhFrenteController.text.trim(),
      'cnhVerso': cnhVersoController.text.trim(),
      'tipoVeiculo': tipoVeiculoSelecionado,
      'marcaModelo': marcaModeloController.text.trim(),
      'anoVeiculo': anoVeiculoController.text.trim(),
      'placa': placaController.text.trim().toUpperCase(),
      'banco': bancoController.text.trim(),
      'agencia': agenciaController.text.trim(),
      'conta': contaController.text.trim(),
      'chavePix': chavePixController.text.trim(),
      'cpfTitularConta': cpfTitularController.text.trim(),
      'regiaoAtuacao': regiaoAtuacaoController.text.trim(),
      'horariosDisponiveis': horariosDisponiveisController.text.trim(),
      'possuiMei': possuiMeiSelecionado,
      'meiCnpj': possuiMeiSelecionado == 'Sim'
          ? _digitsOnly(meiCnpjController.text.trim())
          : null,
      'meiNomeEmpresa': possuiMeiSelecionado == 'Sim'
          ? meiNomeEmpresaController.text.trim()
          : null,
      'latitude': 0.0,
      'longitude': 0.0,
    });

    isLoading = false;
    errorMessage = result.success ? '' : result.message;
    notifyListeners();

    if (!result.success || result.token == null || !context.mounted) return;

    await AuthStorage().saveToken(result.token!);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.entregadorCadastrado)),
    );

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _cepDebounce?.cancel();
    pageController.dispose();

    nomeCompletoController.dispose();
    cpfController.dispose();
    rgController.dispose();
    dataNascimentoController.dispose();
    selfieController.dispose();
    nomeContatoEmergenciaController.dispose();
    telefoneEmergenciaController.dispose();

    telefoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    complementoController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();

    cnhNumeroController.dispose();
    cnhValidadeController.dispose();
    cnhFrenteController.dispose();
    cnhVersoController.dispose();

    marcaModeloController.dispose();
    anoVeiculoController.dispose();
    placaController.dispose();

    bancoController.dispose();
    agenciaController.dispose();
    contaController.dispose();
    chavePixController.dispose();
    cpfTitularController.dispose();

    regiaoAtuacaoController.dispose();
    horariosDisponiveisController.dispose();
    meiCnpjController.dispose();
    meiNomeEmpresaController.dispose();

    super.dispose();
  }
}
