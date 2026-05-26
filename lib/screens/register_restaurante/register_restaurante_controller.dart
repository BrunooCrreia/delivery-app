import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/services/cep_service.dart';

class RegisterRestauranteController extends ChangeNotifier {
  RegisterRestauranteController({CepService? cepService})
    : _cepService = cepService ?? CepService();

  final CepService _cepService;

  final PageController pageController = PageController();
  int currentPage = 0;

  final formKey1 = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey2 = GlobalKey<FormState>();
  final cpfCnpjController = TextEditingController();
  final taxaEntregaController = TextEditingController();

  final formKey3 = GlobalKey<FormState>();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final cepController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool isLoading = false;
  bool isCepLoading = false;
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
      unawaited(_blinkNumeroField());
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

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final authService = AuthService();
    final result = await authService.register({
      'nome': nomeController.text.trim(),
      'email': emailController.text.trim(),
      'telefone': _digitsOnly(telefoneController.text.trim()),
      'password': passwordController.text,
      'tipo': 'RESTAURANTE',
      'latitude': double.tryParse(latitudeController.text.trim()) ?? 0.0,
      'longitude': double.tryParse(longitudeController.text.trim()) ?? 0.0,
      'endereco': enderecoController.text.trim(),
      'numero': numeroController.text.trim(),
      'bairro': bairroController.text.trim(),
      'cidade': cidadeController.text.trim(),
      'estado': estadoController.text.trim(),
      'cep': cepController.text.trim(),
      'cpfCnpj': cpfCnpjController.text.trim(),
      'taxaEntrega': double.tryParse(taxaEntregaController.text.trim()) ?? 0.0,
      'fotoUrl': null,
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

    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    cpfCnpjController.dispose();
    taxaEntregaController.dispose();

    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.dispose();
  }
}
