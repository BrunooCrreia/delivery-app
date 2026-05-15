import 'package:flutter/material.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/screens/widgets/register_progress_bar.dart';
import 'package:projeto_perguntas/screens/widgets/register_error.dart';
import 'package:projeto_perguntas/screens/widgets/register_section_title.dart';
import 'package:projeto_perguntas/screens/widgets/register_field.dart';

class RegisterRestauranteScreen extends StatefulWidget {
  const RegisterRestauranteScreen({super.key});

  @override
  State<RegisterRestauranteScreen> createState() =>
      _RegisterRestauranteScreenState();
}

class _RegisterRestauranteScreenState extends State<RegisterRestauranteScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Etapa 1: Dados da conta ───────────────────────────────────────────────
  final _formKey1 = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Etapa 2: Dados do restaurante ─────────────────────────────────────────
  final _formKey2 = GlobalKey<FormState>();
  final _cpfCnpjController = TextEditingController();
  final _taxaEntregaController = TextEditingController();

  // ── Etapa 3: Endereço + Localização ───────────────────────────────────────
  final _formKey3 = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfCnpjController.dispose();
    _taxaEntregaController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _nextPage(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return;
    setState(() => _errorMessage = '');
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey3.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authService = AuthService();
    final result = await authService.register({
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'tipo': 'RESTAURANTE',
      'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      'endereco': _enderecoController.text.trim(),
      'numero': _numeroController.text.trim(),
      'bairro': _bairroController.text.trim(),
      'cidade': _cidadeController.text.trim(),
      'estado': _estadoController.text.trim(),
      'cep': _cepController.text.trim(),
      'cpfCnpj': _cpfCnpjController.text.trim(),
      'taxaEntrega': double.tryParse(_taxaEntregaController.text.trim()) ?? 0.0,
      'fotoUrl': null,
    });

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = result.success ? '' : result.message;
    });

    if (result.success) {
      if (result.token != null && result.token!.isNotEmpty) {
        await AuthStorage().saveToken(result.token!);
        if (!mounted) return;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cadastroRestaurante),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: RegisterProgressBar(currentPage: _currentPage, totalPages: 3),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [_buildEtapa1(), _buildEtapa2(), _buildEtapa3()],
      ),
    );
  }

  // ── Etapa 1: Dados da conta ───────────────────────────────────────────────

  Widget _buildEtapa1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(
              title: AppStrings.dadosConta,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa1de3),
            const SizedBox(height: 20),
            RegisterField(
              controller: _nomeController,
              label: AppStrings.nomeRestaurante,
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: _emailController,
              label: AppStrings.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeEmail;
                }
                if (!value.contains('@')) {
                  return AppStrings.emailInvalido;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: _passwordController,
              label: AppStrings.senha,
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.informeSenha;
                }
                if (value.length < 6) {
                  return AppStrings.minimo6Caracteres;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: _confirmPasswordController,
              label: AppStrings.confirmarSenha,
              icon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.confirmeSenha;
                }
                if (value != _passwordController.text) {
                  return AppStrings.senhasNaoConferem;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _nextPage(_formKey1),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(AppStrings.proximo),
            ),
          ],
        ),
      ),
    );
  }

  // ── Etapa 2: Dados do restaurante ─────────────────────────────────────────

  Widget _buildEtapa2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(
              title: AppStrings.dadosRestaurante,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa2de3),
            const SizedBox(height: 20),
            RegisterField(
              controller: _cpfCnpjController,
              label: AppStrings.cpfCnpj,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: _taxaEntregaController,
              label: AppStrings.taxaEntrega,
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeTaxaEntrega;
                }
                if (double.tryParse(value.trim()) == null) {
                  return AppStrings.valorInvalido;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevPage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.voltar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _nextPage(_formKey2),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.proximo),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Etapa 3: Endereço + Localização ───────────────────────────────────────

  Widget _buildEtapa3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegisterSectionTitle(
              title: AppStrings.endereco,
              useMedium: true,
            ),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa3de3),
            const SizedBox(height: 20),
            RegisterField(
              controller: _enderecoController,
              label: AppStrings.endereco,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RegisterField(
                    controller: _bairroController,
                    label: AppStrings.bairro,
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: _numeroController,
                    label: AppStrings.numero,
                    icon: Icons.tag,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RegisterField(
                    controller: _cidadeController,
                    label: AppStrings.cidade,
                    icon: Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: _estadoController,
                    label: AppStrings.estado,
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RegisterField(
              controller: _cepController,
              label: AppStrings.cep,
              icon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            const RegisterSectionTitle(
              title: AppStrings.localizacao,
              useMedium: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RegisterField(
                    controller: _latitudeController,
                    label: AppStrings.latitude,
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.obrigatorio;
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return AppStrings.invalido;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RegisterField(
                    controller: _longitudeController,
                    label: AppStrings.longitude,
                    icon: Icons.my_location_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.obrigatorio;
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return AppStrings.invalido;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              RegisterError(message: _errorMessage),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevPage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(AppStrings.voltar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(AppStrings.cadastrarRestaurante),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
