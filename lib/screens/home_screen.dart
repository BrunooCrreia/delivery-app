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
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _VagasTab(),
    _AgendamentosTab(),
    _SettingsTab(),
  ];

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
        title: const Text('Trans Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Vagas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const _HomeCard(
            title: 'Meus agendamentos',
            description: 'Acompanhe seus agendamentos ativos e futuros.',
            icon: Icons.delivery_dining_sharp,
          ),
        ],
      ),
    );
  }
}

// ─── Vagas Tab ────────────────────────────────────────────────────────────────

class _VagasTab extends StatefulWidget {
  const _VagasTab();

  @override
  State<_VagasTab> createState() => _VagasTabState();
}

class _VagasTabState extends State<_VagasTab> {
  final ApiService _apiService = ApiService();
  List<VagaEntity> _vagas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVagas();
  }

  Future<void> _loadVagas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vagas = await _apiService.getVagas();
      if (!mounted) return;
      setState(() {
        _vagas = vagas;
        _isLoading = false;
      });
    } on TokenException catch (e) {
      if (!mounted) return;
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vagas disponíveis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadVagas,
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade800),
              ),
            )
          else if (_vagas.isEmpty)
            const Center(child: Text('Nenhuma vaga disponível no momento.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _vagas.length,
                itemBuilder: (context, index) {
                  final vaga = _vagas[index];
                  return _VagaItem(vaga: vaga);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Agendamentos Tab ─────────────────────────────────────────────────────────

class _AgendamentosTab extends StatelessWidget {
  const _AgendamentosTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Agendamentos — em breve'));
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings — em breve'));
  }
}

// ─── Componentes compartilhados ───────────────────────────────────────────────

class _VagaItem extends StatelessWidget {
  final VagaEntity vaga;

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
        title: Text(vaga.descricao),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navegar para detalhes da vaga
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
