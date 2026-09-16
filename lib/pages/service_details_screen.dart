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

  Service _latest(BuildContext context) {
    return context.read<ServiceProvider>().services
            .where((item) => item.url == widget.service.url)
            .firstOrNull ??
        widget.service;
  }

  Future<void> _testNow() async {
    setState(() => _testing = true);
    await context.read<ServiceProvider>().fetchServices();
    if (mounted) setState(() => _testing = false);
  }

  Color _statusColor(ServiceStatus s) => s == ServiceStatus.operational
      ? const Color(0xff28a745)
      : s == ServiceStatus.degraded
          ? const Color(0xffff9800)
          : const Color(0xffdc3545);

  IconData _statusIcon(ServiceStatus s) => s == ServiceStatus.operational
      ? Icons.check
      : s == ServiceStatus.degraded
          ? Icons.priority_high
          : Icons.close;

  String _statusLabel(ServiceStatus s) => s == ServiceStatus.operational
      ? 'Opérationnel'
      : s == ServiceStatus.degraded
          ? 'Dégradé'
          : 'Indisponible';

  @override
  Widget build(BuildContext context) {
    context.watch<ServiceProvider>();
    final current = _latest(context);
    final p = context.read<ServiceProvider>();
    final color = _statusColor(current.status);

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        backgroundColor: const Color(0xfff8f9fa),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Détails du service',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: color,
              child: Icon(_statusIcon(current.status),
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              current.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(child: _badge(_statusLabel(current.status), color)),
            const SizedBox(height: 24),
            _MetricsCard(service: current),
            const SizedBox(height: 16),
            _DescriptionCard(service: current),
            const SizedBox(height: 16),
            _HistoryCard(history: p.historyFor(current.url), current: current),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _testing ? null : _testNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2196f3),
                  foregroundColor: Colors.white,
                ),
                icon: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.restart_alt_rounded),
                label: Text(
                  _testing ? 'Test en cours...' : 'Tester maintenant',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      );
}

class _MetricsCard extends StatelessWidget {
  final Service service;
  const _MetricsCard({required this.service});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            _MetricRow(
                icon: Icons.access_time,
                label: 'Temps de réponse',
                value: service.status == ServiceStatus.down
                    ? '—'
                    : '${service.responseTime} ms'),
            const Divider(height: 1),
            _MetricRow(
                icon: Icons.check_circle_outline,
                label: 'Disponibilité (uptime)',
                value: service.status == ServiceStatus.down
                    ? 'Indisponible'
                    : '99.98%'),
            const Divider(height: 1),
            _MetricRow(
                icon: Icons.calendar_today_outlined,
                label: 'Dernière vérification',
                value: _date(service.lastChecked)),
            const Divider(height: 1),
            _MetricRow(
                icon: Icons.link,
                label: 'Endpoint',
                value: service.url,
                multiline: true),
          ]),
        ),
      );

  String _date(DateTime v) =>
      '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}/${v.year} - ${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  const _MetricRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.multiline = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: const Color(0xff607d8b), size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Color(0xff5f6368))),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                maxLines: multiline ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

class _DescriptionCard extends StatelessWidget {
  final Service service;
  const _DescriptionCard({required this.service});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(_description(service),
                    style: const TextStyle(
                        height: 1.6, fontSize: 15, color: Color(0xff5f6368))),
              ]),
        ),
      );

  String _description(Service s) {
    switch (s.url) {
      case 'https://api.github.com':
        return "Point d'entrée principal de l'API REST de GitHub. Ce service permet l'authentification OAuth/PAT, la gestion des dépôts Git, le suivi des issues, des pull requests, des webhooks et l'automatisation CI/CD via GitHub Actions. Il constitue le socle d'intégration pour le versionnement et la collaboration des développeurs.";
      case 'https://freeopenapi.dev':
        return 'Passerelle publique d’API ouvertes et gratuites. Ce service fournit des endpoints normalisés pour tester des intégrations REST, simuler des flux de données externes (météo, devises, données de test) et valider la résilience des clients HTTP sans nécessiter de clé d’authentification payante.';
      case 'https://www.cloudflare.com':
        return 'Infrastructure mondiale de diffusion de contenu (CDN), de routage Anycast et de sécurité réseau. Ce service assure la protection anti-DDoS, la terminaison TLS/SSL, la mise en cache périphérique et la résolution DNS à ultra-faible latence pour des millions d’applications et de sites web.';
      case 'https://httpbin.org/status/200':
        return 'Endpoint standard de référence fourni par Httpbin pour valider la connectivité réseau. Il répond systématiquement par un code d’état HTTP 200 OK avec un payload vide, servant d’étalon pour mesurer la latence réseau brute, la validité de la pile TCP/IP et le bon fonctionnement des requêtes clientes.';
      case 'https://httpbin.org/status/503':
        return 'Endpoint de simulation d’anomalie réseau fourni par Httpbin. Il renvoie délibérément un code d’erreur HTTP 503 Service Unavailable afin de tester la robustesse des intercepteurs, la détection automatique des pannes dans l’application et le basculement vers les mécanismes de secours hors connexion.';
      case 'https://fakestoreapi.com/products':
        return 'API REST publique de simulation e-commerce fournissant des endpoints de test pour les catalogues de produits, les catégories, les paniers d’achat et l’authentification des clients.';
      case 'https://dummyjson.com/products':
        return 'API de simulation de données e-commerce haute performance. Elle fournit des jeux de données complets incluant produits, stocks, marques, évaluations utilisateurs et pagination pour tester des architectures frontend/mobile.';
      case 'https://api.escuelajs.co/api/v1/products':
        return 'API e-commerce complète développée pour l’apprentissage et le prototypage. Elle simule des opérations CRUD sur les produits, les catégories, les utilisateurs ainsi que la gestion de tokens JWT.';
      default:
        return 'Service réseau externe monitoré par StatusDesk. Cette ressource fait l’objet de vérifications périodiques automatisées pour mesurer sa disponibilité, son temps de réponse en millisecondes et son intégrité opérationnelle.';
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final List<Service> history;
  final Service current;
  const _HistoryCard({required this.history, required this.current});

  @override
  Widget build(BuildContext context) {
    final entries = history.isEmpty ? [current] : history;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Historique',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...entries.map((entry) => _HistoryRow(service: entry)),
            ]),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final Service service;
  const _HistoryRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = service.status == ServiceStatus.operational
        ? const Color(0xff28a745)
        : service.status == ServiceStatus.degraded
            ? const Color(0xffff9800)
            : const Color(0xffdc3545);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(
            service.status == ServiceStatus.operational
                ? Icons.check_circle
                : service.status == ServiceStatus.degraded
                    ? Icons.warning_rounded
                    : Icons.cancel,
            color: color,
            size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_time(service.lastChecked),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(_label(service.status),
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
        ),
        Text(
            service.status == ServiceStatus.down
                ? '—'
                : '${service.responseTime} ms',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  String _time(DateTime v) =>
      '${v.day.toString().padLeft(2, '0')}/${v.month.toString().padLeft(2, '0')}, ${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
  String _label(ServiceStatus s) => s == ServiceStatus.operational
      ? 'Opérationnel'
      : s == ServiceStatus.degraded
          ? 'Dégradé'
          : 'Indisponible';
}