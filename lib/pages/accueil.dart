import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';
import 'service_details_screen.dart';

class Accueil extends StatefulWidget { 
  const Accueil({super.key}); 
  @override 
  State<Accueil> createState() => _AccueilState(); 
}

class _AccueilState extends State<Accueil> {
  String _query = ''; 
  bool _showIssuesOnly = false;

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
    final services = provider.services;
    final operational = services.where((s) => s.status == ServiceStatus.operational).length;
    final degraded = services.where((s) => s.status == ServiceStatus.degraded).length; 
    final down = services.where((s) => s.status == ServiceStatus.down).length;
    final statusColor = down > 0 ? const Color(0xffdc3545) : degraded > 0 ? const Color(0xffff9800) : const Color(0xff28a745);
    final filtered = services.where((s) => s.name.toLowerCase().contains(_query.toLowerCase()) && (!_showIssuesOnly || s.status != ServiceStatus.operational)).toList();
    
    // Thème et couleurs dynamiques
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xff121212) : const Color(0xfff7f8fa);
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
                Text('StatusDesk', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textColor)), 
                IconButton(
                  onPressed: provider.isLoading ? null : provider.fetchServices, 
                  icon: provider.isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.refresh, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 20), 
            _StatusBanner(
              color: statusColor, 
              hasIncident: down > 0 || degraded > 0, 
              message: down > 0 ? 'Des services sont actuellement indisponibles.' : degraded > 0 ? 'Certains services rencontrent des ralentissements.' : 'Tout fonctionne bien ! Aucun incident majeur en cours.', 
              lastSync: provider.lastSync,
            ), 
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Opérationnels', count: operational, color: const Color(0xff28a745), icon: Icons.check_circle)), 
                const SizedBox(width: 8), 
                Expanded(child: _MetricCard(label: 'Dégradé', count: degraded, color: const Color(0xffff9800), icon: Icons.warning_rounded)), 
                const SizedBox(width: 8), 
                Expanded(child: _MetricCard(label: 'Indisponible', count: down, color: const Color(0xffdc3545), icon: Icons.cancel)),
              ],
            ), 
            const SizedBox(height: 28),
            Text('Services', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: textColor)), 
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) => setState(() => _query = value), 
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Rechercher un service...', 
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade400 : Colors.grey), 
                suffixIcon: IconButton(onPressed: () => setState(() => _showIssuesOnly = !_showIssuesOnly), icon: Icon(Icons.tune, color: _showIssuesOnly ? statusColor : (isDark ? Colors.grey.shade400 : Colors.grey))), 
                filled: true, 
                fillColor: isDark ? const Color(0xff1e1e1e) : Colors.white, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ), 
            const SizedBox(height: 12),
            if (provider.isLoading && services.isEmpty) 
              const Center(child: Padding(padding: EdgeInsets.all(36), child: CircularProgressIndicator())) 
            else if (provider.error != null && services.isEmpty) 
              _ErrorState(message: provider.error!, onRetry: provider.fetchServices) 
            else if (filtered.isEmpty) 
              Center(child: Padding(padding: const EdgeInsets.all(30), child: Text('Aucun service trouvé.', style: TextStyle(color: textColor)))) 
            else 
              ...filtered.map((service) => _ServiceCard(service: service)),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget { 
  final Color color; 
  final bool hasIncident; 
  final String message; 
  final DateTime? lastSync; 
  
  const _StatusBanner({required this.color, required this.hasIncident, required this.message, required this.lastSync});
  
  @override 
  Widget build(BuildContext context) { 
    final hour = DateTime.now().hour; 
    final greeting = hour >= 18 || hour < 5 ? 'Bonsoir' : 'Bonjour'; 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);
    
    return Card(
      elevation: 0, 
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ), 
      child: Padding(
        padding: const EdgeInsets.all(18), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(hasIncident ? Icons.priority_high : Icons.check, color: Colors.white)), 
            const SizedBox(width: 14), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('$greeting !', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: textColor)), 
                  const SizedBox(height: 3), 
                  Text("Voici l'état de vos services.", style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)), 
                  const SizedBox(height: 8), 
                  Text(message, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)), 
                  const SizedBox(height: 10), 
                  Text('Dernière synchro : ${_formatSync(lastSync)}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    ); 
  }

  String _formatSync(DateTime? value) => value == null ? 'En attente' : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'; 
}

class _MetricCard extends StatelessWidget { 
  final String label; 
  final int count; 
  final Color color; 
  final IconData icon; 
  
  const _MetricCard({required this.label, required this.count, required this.color, required this.icon}); 
  
  @override 
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8), 
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(13), 
        border: Border.all(color: color.withValues(alpha: 0.35)), 
      ), 
      child: Column(
        children: [
          Icon(icon, color: color, size: 23), 
          const SizedBox(height: 6), 
          Text('$count', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: color)), 
          const SizedBox(height: 2), 
          FittedBox(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
        ],
      ),
    ); 
  }
}

class _ServiceCard extends StatelessWidget { 
  final Service service; 
  
  const _ServiceCard({required this.service}); 
  
  @override 
  Widget build(BuildContext context) { 
    final color = service.status == ServiceStatus.operational ? const Color(0xff28a745) : service.status == ServiceStatus.degraded ? const Color(0xffff9800) : const Color(0xffdc3545); 
    final label = service.status == ServiceStatus.operational ? 'Opérationnel' : service.status == ServiceStatus.degraded ? 'Dégradé' : 'Indisponible'; 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xff1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff1e293b);
    
    return Card(
      elevation: 0, 
      margin: const EdgeInsets.only(bottom: 10), 
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
      ), 
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))), 
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14), 
          child: Icon(service.status == ServiceStatus.operational ? Icons.check : service.status == ServiceStatus.degraded ? Icons.warning_rounded : Icons.close, color: color),
        ), 
        title: Text(service.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)), 
        subtitle: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)), 
        trailing: Text('${service.responseTime} ms', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
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
      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)), 
      const SizedBox(height: 10), 
      ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
    ],
  ); 
}