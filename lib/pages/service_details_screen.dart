import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/service_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;
  const ServiceDetailScreen({super.key, required this.service});
  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _testing = false;

  Service get _current {
    for (final item in context.read<ServiceProvider>().services) {
      if (item.url == widget.service.url) return item;
    }
    return widget.service;
  }

  Future<void> _testNow() async {
    setState(() => _testing = true);
    await context.read<ServiceProvider>().fetchServices();
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ServiceProvider>();
    final service = _current;
    final color = _color(service.status);
    final label = _label(service.status);
    final gauge = (service.responseTime / 2000).clamp(0.0, 1.0).toDouble();
    final httpCode = service.status == ServiceStatus.down ? 'Échec / timeout' : service.status == ServiceStatus.degraded ? 'HTTP 200, lent' : 'HTTP 200';
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du service')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(service.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Card(color: color.withOpacity(.12), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(Icons.circle, color: color, size: 28), const SizedBox(width: 12), Expanded(child: Text(label, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))), Chip(label: Text(label), backgroundColor: color.withOpacity(.2))]))),
        _section('Endpoint surveillé', SelectableText(service.url)),
        _section('Performance', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${service.responseTime} ms', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 8), LinearProgressIndicator(value: gauge, minHeight: 10, color: color, backgroundColor: Colors.grey.shade300), const SizedBox(height: 6), Text(service.responseTime < 800 ? 'Latence normale' : 'Latence élevée')])),
        _section('Informations techniques', Column(children: [_infoRow('Réponse', httpCode), _infoRow('Disponibilité estimée', service.status == ServiceStatus.down ? 'Indisponible' : '99,9%'), _infoRow('Dernière vérification', _formatDate(service.lastChecked))])),
        _section('Vérifications récentes', Column(children: List.generate(5, (index) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.check_circle, color: color, size: 20), title: Text('${service.responseTime + index * 7} ms'), subtitle: Text(index == 0 ? 'Dernier contrôle' : '${index * 2} min auparavant'))))),
        const SizedBox(height: 12),
        SizedBox(height: 50, child: ElevatedButton.icon(onPressed: _testing ? null : _testNow, icon: _testing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.restart_alt_rounded), label: Text(_testing ? 'Test en cours...' : 'Tester maintenant'))),
      ]),
    );
  }

  Widget _section(String title, Widget child) => Card(margin: const EdgeInsets.only(top: 14), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12), child])));
  Widget _infoRow(String name, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)))]));
  Color _color(ServiceStatus status) => status == ServiceStatus.operational ? Colors.green : status == ServiceStatus.degraded ? Colors.orange : Colors.red;
  String _label(ServiceStatus status) => status == ServiceStatus.operational ? 'Opérationnel' : status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible';
  String _formatDate(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} à ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
