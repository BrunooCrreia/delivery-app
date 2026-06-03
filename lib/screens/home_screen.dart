import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/auth_storage.dart';
import '../services/vagas_service.dart';
import '../utils/http_client.dart';
import '../utils/map_tile_provider.dart';
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

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  static const LatLng _defaultCenter = LatLng(-23.5505, -46.6333);

  Position? _position;
  bool _locationLoading = true;
  bool _disponivel = false;
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _locationLoading = false);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationLoading = false);
      return;
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // só atualiza ao mover 10 metros
      ),
    ).listen((pos) {
      if (!mounted) return;
      final isFirst = _position == null;
      setState(() {
        _position = pos;
        _locationLoading = false;
      });
      if (isFirst) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
        });
      }
    });
  }

  void _centerOnUser() {
    if (_position != null) {
      _mapController.move(
        LatLng(_position!.latitude, _position!.longitude),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locationLoading) {
      return _LocationLoadingScreen();
    }

    final center = _position != null
        ? LatLng(_position!.latitude, _position!.longitude)
        : _defaultCenter;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: center, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate:
                  'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.transdelivery.app',
              tileProvider: CachedTileProvider(),
            ),
            if (_position != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 60,
                    height: 60,
                    child: const _LocationMarker(),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopStatusBar(
            disponivel: _disponivel,
            loading: _locationLoading,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 148,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: _centerOnUser,
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            child: const Icon(Icons.my_location),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomStatusCard(
            disponivel: _disponivel,
            onToggle: (v) => setState(() => _disponivel = v),
            onVagasTap: () {},
          ),
        ),
      ],
    );
  }
}

// ─── Tela de carregamento de localização ─────────────────────────────────────

class _LocationLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_searching,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Obtendo sua localização...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location marker animado ─────────────────────────────────────────────────

class _LocationMarker extends StatefulWidget {
  const _LocationMarker();

  @override
  State<_LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<_LocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.4, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) => Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: _opacity.value),
              ),
            ),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade600,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Overlay superior ────────────────────────────────────────────────────────

class _TopStatusBar extends StatelessWidget {
  final bool disponivel;
  final bool loading;

  const _TopStatusBar({required this.disponivel, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: disponivel ? Colors.green.shade600 : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: disponivel ? Colors.greenAccent : Colors.white54,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  disponivel ? 'Disponível' : 'Indisponível',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (loading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Card inferior de status ─────────────────────────────────────────────────

class _BottomStatusCard extends StatelessWidget {
  final bool disponivel;
  final ValueChanged<bool> onToggle;
  final VoidCallback onVagasTap;

  const _BottomStatusCard({
    required this.disponivel,
    required this.onToggle,
    required this.onVagasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disponivel ? 'Você está disponível' : 'Você está indisponível',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      disponivel
                          ? 'Aguardando novas solicitações'
                          : 'Ative para receber solicitações',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: disponivel,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onVagasTap,
              icon: const Icon(Icons.work_outline),
              label: const Text('Ver vagas disponíveis'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
  final VagasService _vagasService = VagasService();
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
      final vagas = await _vagasService.getVagas();
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
        onTap: () {},
      ),
    );
  }
}
