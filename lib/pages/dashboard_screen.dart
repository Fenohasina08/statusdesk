import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';
import '../widgets/dashboard/dashboard_grid.dart';
import '../widgets/dashboard/dashboard_states.dart';
import '../widgets/dashboard/search_bar_widget.dart';
import '../widgets/dashboard/status_filter_chips.dart';

/// Orchestrateur mince : il relie le provider aux composants purement visuels.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  ServiceStatus? _selectedStatus;
  String _query = '';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Service> _filtered(List<Service> services) => services.where((service) {
    return service.name.toLowerCase().contains(_query.trim().toLowerCase()) &&
        (_selectedStatus == null || service.status == _selectedStatus);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final services = _filtered(provider.services);
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(title: const Text('Tableau de bord'), backgroundColor: const Color(0xFF263238), foregroundColor: Colors.white, elevation: 0),
      body: RefreshIndicator(
        color: const Color(0xFF4CAF50), backgroundColor: const Color(0xFF37474F),
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DashboardSearchBar(controller: _searchController, onChanged: (value) => setState(() => _query = value)),
            const SizedBox(height: 12),
            StatusFilterChips(selectedStatus: _selectedStatus, onSelected: (value) => setState(() => _selectedStatus = value)),
          ])),
          if (provider.isLoading && provider.services.isEmpty)
            const SliverFillRemaining(child: DashboardLoadingState())
          else if (provider.error != null && provider.services.isEmpty)
            SliverFillRemaining(child: DashboardErrorState(message: provider.error!, onRetry: () => context.read<ServiceProvider>().fetchServices()))
          else if (services.isEmpty)
            const SliverFillRemaining(child: DashboardEmptyState())
          else
            SliverToBoxAdapter(child: DashboardGrid(services: services)),
        ]),
      ),
    );
  }
}
