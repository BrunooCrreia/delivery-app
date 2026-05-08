import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/api_service.dart';
import '../utils/http_client.dart';
import '../core/entities/vagas_entity.dart';
import 'package:projeto_perguntas/core/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Vaga> _vagas = [];
  bool _isLoadingVagas = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVagas();
  }

  Future<void> _loadVagas() async {
    setState(() {
      _isLoadingVagas = true;
      _errorMessage = null;
    });

    try {
      final vagas = await _apiService.getVagas();
      if (!mounted) return;

      setState(() {
        _vagas = vagas;
        _isLoadingVagas = false;
      });
    } on TokenException catch (e) {
      if (!mounted) return;

      // Token expired or invalid - redirect to login
      await AuthStorage().logout();
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro ao carregar vagas: $e';
        _isLoadingVagas = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthStorage().logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home do motoboy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bem-vindo ao Trans Delivery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aqui você encontra suas entregas e as vagas disponíveis.',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  const _HomeCard(
                    title: 'Meus agendamentos',
                    description:
                        'Acompanhe seus agendamentos ativos e futuros.',
                    icon: Icons.delivery_dining_sharp,
                  ),
                  const SizedBox(height: 14),
                  _VagasCard(
                    vagas: _vagas,
                    isLoading: _isLoadingVagas,
                    errorMessage: _errorMessage,
                    onRefresh: _loadVagas,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VagasCard extends StatelessWidget {
  final List<Vaga> vagas;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const _VagasCard({
    required this.vagas,
    required this.isLoading,
    this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vagas disponíveis',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Novas oportunidades de entregas próximas a você.',
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Atualizar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              )
            else if (vagas.isEmpty)
              const Center(child: Text('Nenhuma vaga disponível no momento.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vagas.length,
                itemBuilder: (context, index) {
                  final vaga = vagas[index];
                  return _VagaItem(vaga: vaga);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _VagaItem extends StatelessWidget {
  final Vaga vaga;

  const _VagaItem({required this.vaga});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.work_outline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(vaga.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vaga.localizacao != null) Text(vaga.localizacao!),
            if (vaga.valor != null)
              Text(
                'R\$ ${vaga.valor!.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to vaga details
        },
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _HomeCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
