import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';
import 'service_details_screen.dart';

class Aceuil extends StatefulWidget {
  const Aceuil({super.key});

  @override
  State<Aceuil> createState() => _AceuilState();
}

class _AceuilState extends State<Aceuil> {
  String _query = '';
  bool _showIssuesOnly = false;

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
    final allServices = provider.services;
    final operational = allServices.where((s) => s.status == ServiceStatus.operational).length;
    final degraded = allServices.where((s) => s.status == ServiceStatus.degraded).length;
    final down = allServices.where((s) => s.status == ServiceStatus.down).length;
    final filteredServices = allServices.where((service) {
      final matchesQuery = service.name.toLowerCase().contains(_query.toLowerCase());
      final matchesStatus = !_showIssuesOnly || service.status != ServiceStatus.operational;
      return matchesQuery && matchesStatus;
    }).toList();
    final hasIncident = down > 0 || degraded > 0;
    final statusColor = down > 0 ? const Color(0xffdc3545) : degraded > 0 ? const Color(0xffff9800) : const Color(0xff28a745);
    final statusMessage = down > 0
        ? 'Des services sont actuellement indisponibles.'
        : degraded > 0
            ? 'Certains services rencontrent des ralentissements.'
            : 'Tout fonctionne bien ! Aucun incident majeur en cours.';

    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      body: RefreshIndicator(
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
          children: [
            _Header(provider: provider),
            const SizedBox(height: 20),
            _StatusBanner(color: statusColor, hasIncident: hasIncident, message: statusMessage, lastSync: provider.lastSync),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) => Row(children: [
              Expanded(child: _MetricCard(label: 'Opérationnels', count: operational, color: const Color(0xff28a745), icon: Icons.check_circle)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Dégradé', count: degraded, color: const Color(0xffff9800), icon: Icons.warning_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _MetricCard(label: 'Indisponible', count: down, color: const Color(0xffdc3545), icon: Icons.cancel)),
            ])),
            const SizedBox(height: 28),
            const Text('Services', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xff202124))),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: _showIssuesOnly ? 'Afficher tous les services' : 'Afficher uniquement les incidents',
                  onPressed: () => setState(() => _showIssuesOnly = !_showIssuesOnly),
                  icon: Icon(Icons.tune, color: _showIssuesOnly ? statusColor : Colors.grey.shade600),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading && allServices.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator()))
            else if (provider.error != null && allServices.isEmpty)
              _ErrorState(message: provider.error!, onRetry: () => context.read<ServiceProvider>().fetchServices())
            else if (filteredServices.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Aucun service trouvé.')))
            else
              ...filteredServices.map((service) => _ServiceCard(service: service)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ServiceProvider provider;
  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('StatusDesk', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -.5)),
        IconButton(
          tooltip: 'Actualiser',
          onPressed: provider.isLoading ? null : () => context.read<ServiceProvider>().fetchServices(),
          icon: provider.isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)) : const Icon(Icons.refresh, size: 28),
        ),
      ]);
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final bool hasIncident;
  final String message;
  final DateTime? lastSync;
  const _StatusBanner({required this.color, required this.hasIncident, required this.message, required this.lastSync});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: color.withOpacity(.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(backgroundColor: color, child: Icon(hasIncident ? Icons.priority_high : Icons.check, color: Colors.white)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bonjour !', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            const Text("Voici l'état de vos services."),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [Icon(Icons.schedule, size: 15, color: Colors.grey.shade700), const SizedBox(width: 5), Text('Dernière synchro : ${_formatSync(lastSync)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700))]),
          ])),
        ])),
      );

  String _formatSync(DateTime? value) {
    if (value == null) return 'En attente';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _MetricCard({required this.label, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(13), border: Border.all(color: color.withOpacity(.35))),
        child: Column(children: [Icon(icon, color: color, size: 23), const SizedBox(height: 6), Text('$count', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), FittedBox(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)))]),
      );
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = service.status == ServiceStatus.operational ? const Color(0xff28a745) : service.status == ServiceStatus.degraded ? const Color(0xffff9800) : const Color(0xffdc3545);
    final label = service.status == ServiceStatus.operational ? 'Opérationnel' : service.status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible';
    final icon = service.status == ServiceStatus.operational ? Icons.check : service.status == ServiceStatus.degraded ? Icons.warning_rounded : Icons.close;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
        leading: CircleAvatar(backgroundColor: color.withOpacity(.14), child: Icon(icon, color: color)),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))))),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text('${service.responseTime} ms', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: Colors.grey)]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(children: [Text(message, textAlign: TextAlign.center), const SizedBox(height: 10), ElevatedButton(onPressed: onRetry, child: const Text('Réessayer'))]);
}
