import 'package:flutter/material.dart';

/// Champ contrôlé et indépendant : le parent décide comment appliquer la recherche.
class DashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const DashboardSearchBar({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, onChanged: onChanged,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Rechercher un service', hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      suffixIcon: controller.text.isEmpty ? null : IconButton(onPressed: controller.clear, icon: const Icon(Icons.clear, color: Colors.white70)),
      filled: true, fillColor: const Color(0xFF37474F),
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Color(0xFF4CAF50))),
    ),
  );
}
