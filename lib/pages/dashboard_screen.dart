import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';
import '../screens/service_detail_screen.dart';

/// Tableau de bord principal : recherche, filtrage et navigation vers le détail.
///
/// Le widget reste volontairement sans état local : le provider porte les
/// données métier, tandis que l'état de saisie et du filtre appartient à l'UI.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  ServiceStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Service> _filteredServices(List<Service> services) {
    final query = _searchController.text.trim().toLowerCase();
    return services.where((service) {
      final matchesName = service.name.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == null || service.status == _selectedStatus;
      return matchesName && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final services = _filteredServices(provider.services);

    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFF37474F),
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildFilters()),
            if (provider.isLoading && provider.services.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (provider.error != null && provider.services.isEmpty)
              SliverFillRemaining(child: _buildError(provider.error!))
            else if (services.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    // Pattern responsive : le nombre de colonnes dépend de la largeur disponible.
                    final columns = width < 600 ? 1 : width <= 1000 ? 2 : (width >= 1400 ? 4 : 3);
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ServiceCard(service: services[index]),
                        childCount: services.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 2.3 : 1.55,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher un service',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.clear, color: Colors.white70),
                    ),
              filled: true,
              fillColor: const Color(0xFF37474F),
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
              enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF4CAF50))),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('Tous', null),
              ...ServiceStatus.values.map((status) => _filterChip(_statusLabel(status), status)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, ServiceStatus? status) {
    final selected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedStatus = status),
      labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
      backgroundColor: const Color(0xFF37474F),
      selectedColor: const Color(0xFF4CAF50),
      checkmarkColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      side: BorderSide(color: selected ? const Color(0xFF4CAF50) : Colors.white24),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.read<ServiceProvider>().fetchServices(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(service.status);
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF37474F),
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(service.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                _StatusBadge(status: service.status),
              ]),
              const Spacer(),
              Text('${service.responseTime} ms', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Vérifié ${_relativeTime(service.lastChecked)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Container(height: 3, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        color: _statusColor(status),
        child: Text(_statusLabel(status), style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Aucun service trouvé.', style: TextStyle(color: Colors.white70)));
}

String _statusLabel(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.operational: return 'Operational';
    case ServiceStatus.degraded: return 'Degraded';
    case ServiceStatus.down: return 'Down';
    case ServiceStatus.unknown: return 'Unknown';
  }
}

Color _statusColor(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.operational: return const Color(0xFF4CAF50);
    case ServiceStatus.degraded: return Colors.amber;
    case ServiceStatus.down: return Colors.red;
    case ServiceStatus.unknown: return Colors.grey;
  }
}

String _relativeTime(DateTime checkedAt) {
  final difference = DateTime.now().difference(checkedAt);
  if (difference.isNegative || difference.inSeconds < 60) return "à l'instant";
  if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'il y a ${difference.inHours} h';
  return 'il y a ${difference.inDays} j';
}
