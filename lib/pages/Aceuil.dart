import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';

class Aceuil extends StatefulWidget {
  const Aceuil({super.key});

  @override
  State<Aceuil> createState() => _AceuilState();
}

class _AceuilState extends State<Aceuil> {
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
    final services = provider.services;
    final operational = services.where((s) => s.status == ServiceStatus.operational).length;
    final degraded = services.where((s) => s.status == ServiceStatus.degraded).length;
    final down = services.where((s) => s.status == ServiceStatus.down).length;
    final overall = down > 0
        ? 'Certains services sont indisponibles'
        : degraded > 0
            ? 'Performances dégradées'
            : services.isEmpty
                ? 'Aucun service surveillé'
                : 'Tous les systèmes sont opérationnels';
    final overallColor = down > 0 ? Colors.red : degraded > 0 ? Colors.orange : Colors.green;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: ListView(padding: const EdgeInsets.fromLTRB(10, 50, 10, 20), children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Status Desk', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => context.read<ServiceProvider>().fetchServices(), icon: const Icon(Icons.refresh)),
          ]),
          const Text('Tableau de bord en temps réel', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Icon(Icons.circle, color: overallColor, size: 32), const SizedBox(width: 10),
            Expanded(child: Text(overall, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          ]))),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _CounterCard('Opérationnel', operational, Colors.green),
            _CounterCard('Dégradé', degraded, Colors.orange),
            _CounterCard('Indisponible', down, Colors.red),
            _CounterCard('Total', services.length, Colors.blue),
          ]),
          const SizedBox(height: 24),
          const Text('Services surveillés', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (provider.isLoading && services.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (provider.error != null && services.isEmpty)
            _ErrorState(message: provider.error!, onRetry: () => context.read<ServiceProvider>().fetchServices())
          else if (services.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Aucun service disponible.')))
          else
            ...services.map((service) => _ServiceTile(service: service)),
        ]),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CounterCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(width: 160, height: 105, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8), Text('$value', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
  ]));
}

class _ServiceTile extends StatelessWidget {
  final Service service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = service.status == ServiceStatus.operational ? Colors.green : service.status == ServiceStatus.degraded ? Colors.orange : Colors.red;
    final label = service.status == ServiceStatus.operational ? 'Opérationnel' : service.status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible';
    return Card(child: ListTile(leading: Icon(Icons.circle, color: color), title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('$label • ${service.responseTime} ms'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)));
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(children: [Text(message, textAlign: TextAlign.center), const SizedBox(height: 10), ElevatedButton(onPressed: onRetry, child: const Text('Réessayer'))]);
}
