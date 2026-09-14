import 'package:flutter/material.dart';

class DashboardLoadingState extends StatelessWidget {
  const DashboardLoadingState({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Aucun service trouvé.', style: TextStyle(color: Colors.white70)));
}

class DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const DashboardErrorState({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48), const SizedBox(height: 12),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)), const SizedBox(height: 16),
    OutlinedButton(onPressed: onRetry, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)), child: const Text('Réessayer')),
  ])));
}
