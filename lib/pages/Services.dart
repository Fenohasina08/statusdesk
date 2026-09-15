import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';
import 'service_details_screen.dart';

class Services extends StatefulWidget {
  const Services({super.key});
  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  String _query = '';
  ServiceStatus? _status;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServiceProvider>();
      if (provider.services.isEmpty && !provider.isLoading) provider.fetchServices();
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final services = provider.services.where((service) => service.name.toLowerCase().contains(_query.toLowerCase()) && (_status == null || service.status == _status)).toList();
    return Scaffold(body: RefreshIndicator(onRefresh: () => context.read<ServiceProvider>().fetchServices(), child: ListView(padding: const EdgeInsets.fromLTRB(10, 50, 10, 20), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Services', style: TextStyle(fontSize: 30)), IconButton(onPressed: () => context.read<ServiceProvider>().fetchServices(), icon: const Icon(Icons.refresh, size: 30))]),
      TextField(onChanged: (value) => setState(() => _query = value), decoration: const InputDecoration(hintText: 'Rechercher', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
      const SizedBox(height: 10), Wrap(spacing: 6, children: [_filter('Tous', null), _filter('Opérationnel', ServiceStatus.operational), _filter('Dégradé', ServiceStatus.degraded), _filter('Indisponible', ServiceStatus.down)]),
      const Divider(),
      if (provider.isLoading && provider.services.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
      else if (provider.error != null && provider.services.isEmpty) Center(child: Column(children: [Text(provider.error!, textAlign: TextAlign.center), ElevatedButton(onPressed: () => context.read<ServiceProvider>().fetchServices(), child: const Text('Réessayer'))]))
      else if (services.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucun service trouvé.')))
      else ...services.map((service) => _ServiceRow(service: service)),
    ])));
  }
  Widget _filter(String label, ServiceStatus? status) => ChoiceChip(label: Text(label), selected: _status == status, onSelected: (_) => setState(() => _status = status));
}

class _ServiceRow extends StatelessWidget {
  final Service service;
  const _ServiceRow({required this.service});
  @override
  Widget build(BuildContext context) {
    final color = service.status == ServiceStatus.operational ? Colors.green : service.status == ServiceStatus.degraded ? Colors.orange : Colors.red;
    final label = service.status == ServiceStatus.operational ? 'Opérationnel' : service.status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible';
    return Card(child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))), leading: Icon(Icons.circle, color: color), title: Text(service.name), subtitle: Text('$label • ${service.responseTime} ms'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)));
  }
}
