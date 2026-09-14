import 'package:flutter/material.dart';

import '../../models/service.dart';
import '../../screens/service_detail_screen.dart';

/// Composant présentational : une carte ne connaît pas le provider.
/// Cette séparation rend le composant testable et réutilisable dans toute grille.
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(service.status);
    return Card(
      margin: EdgeInsets.zero, elevation: 0, color: const Color(0xFF37474F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(service.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), color: color, child: Text(statusLabel(service.status), style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))),
            ]),
            const Spacer(),
            Text('${service.responseTime} ms', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Vérifié ${relativeTime(service.lastChecked)}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Container(height: 3, color: color),
          ]),
        ),
      ),
    );
  }
}

String statusLabel(ServiceStatus status) => switch (status) {
  ServiceStatus.operational => 'Operational', ServiceStatus.degraded => 'Degraded',
  ServiceStatus.down => 'Down', ServiceStatus.unknown => 'Unknown',
};

Color statusColor(ServiceStatus status) => switch (status) {
  ServiceStatus.operational => const Color(0xFF4CAF50), ServiceStatus.degraded => Colors.amber,
  ServiceStatus.down => Colors.red, ServiceStatus.unknown => Colors.grey,
};

String relativeTime(DateTime value) {
  final d = DateTime.now().difference(value);
  if (d.isNegative || d.inSeconds < 60) return "à l'instant";
  if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
  if (d.inHours < 24) return 'il y a ${d.inHours} h';
  return 'il y a ${d.inDays} j';
}
