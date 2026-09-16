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
      if (provider.services.isEmpty && !provider.isLoading) {
        provider.fetchServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();
    final services = provider.services.where((service) {
      final query = _query.toLowerCase();
      final matchesSearch = service.name.toLowerCase().contains(query) ||
          service.url.toLowerCase().contains(query);
      return matchesSearch && (_status == null || service.status == _status);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: RefreshIndicator(
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Services',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => context.read<ServiceProvider>().fetchServices(),
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 27),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _filter('Tous', null),
                _filter('Opérationnels', ServiceStatus.operational),
                _filter('Dégradés', ServiceStatus.degraded),
                _filter('Indisponibles', ServiceStatus.down),
              ]),
            ),
            const SizedBox(height: 14),
            if (provider.isLoading && provider.services.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(36),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.error != null && provider.services.isEmpty)
              _ErrorState(
                message: provider.error!,
                onRetry: () => context.read<ServiceProvider>().fetchServices(),
              )
            else if (services.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('Aucun service trouvé.'),
                ),
              )
            else
              ...services.map((service) => _ServiceRow(service: service)),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, ServiceStatus? status) {
    final selected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xff343a40),
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xff2196f3),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xff2196f3) : Colors.grey.shade300,
        ),
        onSelected: (_) => setState(() => _status = status),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Service service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final color = service.status == ServiceStatus.operational
        ? const Color(0xff28a745)
        : service.status == ServiceStatus.degraded
            ? const Color(0xffff9800)
            : const Color(0xffdc3545);
    final label = service.status == ServiceStatus.operational
        ? 'Opérationnel'
        : service.status == ServiceStatus.degraded
            ? 'Dégradé'
            : 'Indisponible';
    final icon = service.status == ServiceStatus.operational
        ? Icons.check
        : service.status == ServiceStatus.degraded
            ? Icons.warning_rounded
            : Icons.close;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(service.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              service.status == ServiceStatus.down
                  ? '—'
                  : '${service.responseTime} ms',
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      );
}