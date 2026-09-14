import 'package:flutter/material.dart';
import '../../models/service.dart';
import 'service_card.dart';

/// Filtre contrôlé : la page possède l'état, ce widget ne fait que l'afficher.
class StatusFilterChips extends StatelessWidget {
  final ServiceStatus? selectedStatus;
  final ValueChanged<ServiceStatus?> onSelected;
  const StatusFilterChips({super.key, required this.selectedStatus, required this.onSelected});

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
    _chip('Tous', null),
    ...ServiceStatus.values.map((s) => _chip(statusLabel(s), s)),
  ]);

  Widget _chip(String label, ServiceStatus? status) {
    final selected = selectedStatus == status;
    return FilterChip(
      label: Text(label), selected: selected, onSelected: (_) => onSelected(status),
      labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
      backgroundColor: const Color(0xFF37474F), selectedColor: const Color(0xFF4CAF50),
      checkmarkColor: Colors.black, elevation: 0, pressElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      side: BorderSide(color: selected ? const Color(0xFF4CAF50) : Colors.white24),
    );
  }
}
