import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';
import 'package:projeto_perguntas/core/resources/app_strings.dart';
import 'package:projeto_perguntas/screens/widgets/termos_entregador_texto.dart';

class RegisterEntregadorScreen extends StatefulWidget {
  const RegisterEntregadorScreen({super.key});

  @override
  State<RegisterEntregadorScreen> createState() =>
      _RegisterEntregadorScreenState();
}

class _RegisterEntregadorScreenState extends State<RegisterEntregadorScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Máscaras ──────────────────────────────────────────────────────────────
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _dataMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  // ── Etapa 1: Dados pessoais ───────────────────────────────────────────────
  final _formKey1 = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  // ── Etapa 2: Acesso ───────────────────────────────────────────────────────
  final _formKey2 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Etapa 3: Endereço + termos ────────────────────────────────────────────
  final _formKey3 = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _aceitouTermos = false;

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    if (!_aceitouTermos) {
      setState(() => _errorMessage = AppStrings.precisaAceitarTermos);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final nomeCompleto =
        '${_nomeController.text.trim()} ${_sobrenomeController.text.trim()}';

    final authService = AuthService();
    final result = await authService.register({
      'nome': nomeCompleto,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'tipo': 'MOTOBOY',
      'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
    });

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = result.success ? '' : result.message;
    });

    if (result.success && result.token != null) {
      await AuthStorage().saveToken(result.token!);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.entregadorCadastrado)),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _abrirTermos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppStrings.termosTitulo,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: const TermosEntregadorTexto(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final labelStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.campoObrigatorio;
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cadastroEntregador),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressBar(currentPage: _currentPage, totalPages: 3),
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

  // ── Etapa 1: Dados pessoais ───────────────────────────────────────────────

  Widget _buildEtapa1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: AppStrings.dadosPessoais),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa1de3),
            const SizedBox(height: 20),
            _buildField(
              controller: _nomeController,
              label: AppStrings.nome,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _sobrenomeController,
              label: AppStrings.sobrenome,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _cpfController,
              label: AppStrings.cpf,
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [_cpfMask], // ✅ máscara CPF
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeCpf;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 11) {
                  return AppStrings.cpfIncompleto;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _dataNascimentoController,
              label: AppStrings.dataNascimento,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [_dataMask], // ✅ máscara data
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeDataNascimento;
                }
                final digits = value.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 8) {
                  return AppStrings.dataIncompleta;
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

  // ── Etapa 2: Acesso ───────────────────────────────────────────────────────

  Widget _buildEtapa2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: AppStrings.emailESenha),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa2de3),
            const SizedBox(height: 20),
            _buildField(
              controller: _emailController,
              label: AppStrings.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.informeEmail;
                }
                if (!value.contains('@')) return AppStrings.emailInvalido;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _passwordController,
              label: AppStrings.senha,
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return AppStrings.informeSenha;
                if (value.length < 6) return AppStrings.minimo6Caracteres;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
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

  // ── Etapa 3: Endereço + termos ────────────────────────────────────────────

  Widget _buildEtapa3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: AppStrings.enderecoResidencial),
            const SizedBox(height: 4),
            const Text(AppStrings.etapa3de3),
            const SizedBox(height: 20),
            _buildField(
              controller: _enderecoController,
              label: AppStrings.endereco,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    controller: _bairroController,
                    label: AppStrings.bairro,
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
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
                  child: _buildField(
                    controller: _cidadeController,
                    label: AppStrings.cidade,
                    icon: Icons.location_city_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _estadoController,
                    label: AppStrings.uf,
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _cepController,
              label: AppStrings.cep,
              icon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(
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
                  child: _buildField(
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
            const SizedBox(height: 24),

            // ── Termos ──────────────────────────────────────────────────────
            Row(
              children: [
                Checkbox(
                  value: _aceitouTermos,
                  onChanged: (value) =>
                      setState(() => _aceitouTermos = value ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _abrirTermos,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: AppStrings.liEAceito),
                          TextSpan(
                            text: AppStrings.termosUso,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              _RegisterError(message: _errorMessage),
            ],

            const SizedBox(height: 24),
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
                        : const Text(AppStrings.criarConta),
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

// ── Componentes ───────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _ProgressBar({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentPage + 1) / totalPages,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _RegisterError extends StatelessWidget {
  final String message;
  const _RegisterError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade800)),
          ),
        ],
      ),
    );
  }
}
