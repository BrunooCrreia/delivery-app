import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/services/cep_service.dart';

class RegisterEntregadorController extends ChangeNotifier {
  RegisterEntregadorController({CepService? cepService})
    : _cepService = cepService ?? CepService();

  final CepService _cepService;

  final PageController pageController = PageController();
  int currentPage = 0;

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final formKey1 = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final cpfController = TextEditingController();
  final dataNascimentoController = TextEditingController();

  final formKey2 = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey3 = GlobalKey<FormState>();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final cepController = TextEditingController();

  bool aceitouTermos = false;
  bool isLoading = false;
  bool isCepLoading = false;
  String errorMessage = '';
  Timer? _cepDebounce;
  String _lastFetchedCep = '';
  int _cepRequestId = 0;

  void setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setAceitouTermos(bool value) {
    aceitouTermos = value;
    notifyListeners();
  }

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

  void prevPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  bool _isNullOrEmpty(dynamic value) {
    return value == null || value.toString().trim().isEmpty;
  }

  bool _isInvalidCepPayload(Map<String, dynamic> data) {
    return _isNullOrEmpty(data['street']) &&
        _isNullOrEmpty(data['neighborhood']) &&
        _isNullOrEmpty(data['city']) &&
        _isNullOrEmpty(data['state']);
  }

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
            content: Text('CEP invalido. Verifique e tente novamente.'),
          ),
        );
        _lastFetchedCep = '';
        return;
      }

      enderecoController.text = (data['street'] as String? ?? '').trim();
      bairroController.text = (data['neighborhood'] as String? ?? '').trim();
      cidadeController.text = (data['city'] as String? ?? '').trim();
      estadoController.text = (data['state'] as String? ?? '').trim();

      final zipCode = (data['zipCode'] as String? ?? '').trim();
      if (zipCode.isNotEmpty) {
        cepController.text = zipCode;
      }

      _lastFetchedCep = cep;
      notifyListeners();
    } catch (_) {
      if (requestId != _cepRequestId) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel buscar o endereco pelo CEP.'),
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
    if (!formKey3.currentState!.validate()) return;
    if (!aceitouTermos) {
      errorMessage = AppStrings.precisaAceitarTermos;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final nomeCompleto =
        '${nomeController.text.trim()} ${sobrenomeController.text.trim()}';

    final authService = AuthService();
    final result = await authService.register({
      'nome': nomeCompleto,
      'email': emailController.text.trim(),
      'password': passwordController.text,
      'tipo': 'MOTOBOY',
      'cpfCnpj': cpfController.text.trim(), // Alterado de 'cpf' para 'cpfCnpj'
      'dataNascimento': dataNascimentoController.text.trim(),
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

    nomeController.dispose();
    sobrenomeController.dispose();
    cpfController.dispose();
    dataNascimentoController.dispose();

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();

    super.dispose();
  }
}
