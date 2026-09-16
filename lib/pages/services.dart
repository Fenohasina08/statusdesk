import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ServiceProvider>();
    final services = provider.services.where((service) {
      final query = _query.toLowerCase();
      final matchesSearch = service.name.toLowerCase().contains(query) ||
          service.url.toLowerCase().contains(query);
      return matchesSearch && (_status == null || service.status == _status);
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xfff8f9fa);
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () => context.read<ServiceProvider>().fetchServices(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 46, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.services,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
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
                      : Icon(Icons.refresh, size: 27, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: l10n.searchServiceHint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                suffixIcon: Icon(
                  Icons.filter_list,
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filter(l10n.all, null, isDark),
                  _filter(l10n.operational, ServiceStatus.operational, isDark),
                  _filter(l10n.degraded, ServiceStatus.degraded, isDark),
                  _filter(l10n.unavailable, ServiceStatus.down, isDark),
                ],
              ),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    l10n.noServicesFound,
                    style: TextStyle(color: textColor),
                  ),
                ),
              )
            else
              ...services.map((service) => _ServiceRow(service: service)),
          ],
        ),
      ),
    );
  }

  Widget _filter(String label, ServiceStatus? status, bool isDark) {
    final selected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.grey.shade300 : const Color(0xff343a40)),
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        selectedColor: const Color(0xff2196f3),
        backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
        side: BorderSide(
          color: selected
              ? const Color(0xff2196f3)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
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
    final l10n = AppLocalizations.of(context)!;
    final color = service.status == ServiceStatus.operational
        ? const Color(0xff28a745)
        : service.status == ServiceStatus.degraded
            ? const Color(0xffff9800)
            : const Color(0xffdc3545);
    final label = service.status == ServiceStatus.operational
        ? l10n.operationalStatus
        : service.status == ServiceStatus.degraded
            ? l10n.degradedStatus
            : l10n.unavailableStatus;
    final icon = service.status == ServiceStatus.operational
        ? Icons.check
        : service.status == ServiceStatus.degraded
            ? Icons.warning_rounded
            : Icons.close;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);

    return Card(
      elevation: 0,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          service.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              service.status == ServiceStatus.down
                  ? '—'
                  : '${service.responseTime} ms',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}