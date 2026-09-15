import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;
  const ServiceDetailScreen({super.key, required this.service});

  Service _latest(BuildContext context) {
    for (final item in context.read<ServiceProvider>().services) {
      if (item.url == service.url) return item;
    }
    return service;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ServiceProvider>();
    final current = _latest(context);
    final color = _statusColor(current.status);
    final label = _statusLabel(current.status);
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xfff8f9fa),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Détails du service', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 24), children: [
          CircleAvatar(radius: 38, backgroundColor: color, child: Icon(_statusIcon(current.status), color: Colors.white, size: 36)),
          const SizedBox(height: 14),
          Text(current.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xff202124))),
          const SizedBox(height: 10),
          Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(24)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 24),
          _MetricsCard(service: current, color: color),
          const SizedBox(height: 16),
          _DescriptionCard(service: current),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2196f3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Retour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }

  Color _statusColor(ServiceStatus status) => status == ServiceStatus.operational ? const Color(0xff28a745) : status == ServiceStatus.degraded ? const Color(0xffff9800) : const Color(0xffdc3545);
  IconData _statusIcon(ServiceStatus status) => status == ServiceStatus.operational ? Icons.check : status == ServiceStatus.degraded ? Icons.priority_high : Icons.close;
  String _statusLabel(ServiceStatus status) => status == ServiceStatus.operational ? 'Opérationnel' : status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible';
}

class _MetricsCard extends StatelessWidget {
  final Service service;
  final Color color;
  const _MetricsCard({required this.service, required this.color});

  @override
  Widget build(BuildContext context) => Card(elevation: 1, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
        _MetricRow(icon: Icons.access_time, label: 'Temps de réponse', value: service.status == ServiceStatus.down ? '—' : '${service.responseTime} ms'),
        const Divider(height: 1),
        _MetricRow(icon: Icons.check_circle_outline, label: 'Disponibilité (uptime)', value: service.status == ServiceStatus.down ? 'Indisponible' : '99.98%'),
        const Divider(height: 1),
        _MetricRow(icon: Icons.calendar_today_outlined, label: 'Dernière vérification', value: _formatDate(service.lastChecked)),
        const Divider(height: 1),
        _MetricRow(icon: Icons.link, label: 'Endpoint', value: service.url, multiline: true),
      ])));

  String _formatDate(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} - ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  const _MetricRow({required this.icon, required this.label, required this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xff607d8b), size: 21), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(color: Color(0xff5f6368))),), const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.right, maxLines: multiline ? 3 : 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff202124))))]));
}

class _DescriptionCard extends StatelessWidget {
  final Service service;
  const _DescriptionCard({required this.service});

  @override
  Widget build(BuildContext context) => Card(elevation: 1, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(_description(service), style: const TextStyle(height: 1.45, color: Color(0xff5f6368)))])));

  String _description(Service service) {
    switch (service.name) {
      case 'GitHub API':
        return "Service responsable de l'authentification et de l'intégration avec les dépôts de code.";
      case 'FreeOpenAPI':
        return 'Service de passerelle API pour les requêtes de données publiques ouvertes.';
      case 'Cloudflare':
        return 'Réseau de diffusion de contenu (CDN) et protection contre les attaques distribuées.';
      case 'Test HTTP 200':
        return 'Endpoint de référence pour valider la connectivité réseau et les réponses HTTP standard.';
      case 'Test indisponible':
        return 'Endpoint simulant une panne de service (HTTP 503 Service Unavailable).';
      default:
        return 'Service responsable du traitement des requêtes et de la gestion des opérations.';
    }
  }
}
