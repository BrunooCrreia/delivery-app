import 'package:flutter/material.dart';
import 'package:projeto_perguntas/services/auth_service.dart';
import 'package:projeto_perguntas/services/auth_storage.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';

class RegisterEntregadorScreen extends StatefulWidget {
  const RegisterEntregadorScreen({super.key});

  @override
  State<RegisterEntregadorScreen> createState() =>
      _RegisterEntregadorScreenState();
}

class _RegisterEntregadorScreenState extends State<RegisterEntregadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authService = AuthService();
    final result = await authService.register({
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'tipo': 'ENTREGADOR',
      'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
      'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
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
          const SnackBar(content: Text('Entregador cadastrado com sucesso!')),
        );

        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro concluido. Faca login para continuar.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
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
              return 'Campo obrigatorio';
            }
            return null;
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Entregador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage.isNotEmpty) ...[
                _RegisterError(message: _errorMessage),
                const SizedBox(height: 16),
              ],

              // ── Dados da conta ──────────────────────────────────────────
              _SectionTitle(title: 'Dados da conta'),
              const SizedBox(height: 12),
              _buildField(
                controller: _nomeController,
                label: 'Nome',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!value.contains('@')) return 'E-mail invalido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a senha';
                  if (value.length < 6) return 'Minimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _confirmPasswordController,
                label: 'Confirmar senha',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme a senha';
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas nao conferem';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ── Localizacao ─────────────────────────────────────────────
              _SectionTitle(title: 'Localizacao'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      icon: Icons.my_location_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatorio';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Invalido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      icon: Icons.my_location_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatorio';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Invalido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
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
                      : const Text('Criar conta'),
                ),
              ),
            ],
          ),
        ),
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
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
