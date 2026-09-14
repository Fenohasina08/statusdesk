import 'package:flutter/material.dart';
import '../../models/service.dart';
import 'service_card.dart';

/// La grille possède uniquement une responsabilité : adapter la présentation à l'espace.
class DashboardGrid extends StatelessWidget {
  final List<Service> services;
  const DashboardGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final columns = width < 600 ? 1 : width <= 1000 ? 2 : (width >= 1400 ? 4 : 3);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: services.length, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: columns == 1 ? 2.3 : 1.55),
      itemBuilder: (_, index) => ServiceCard(service: services[index]),
    );
  });
}
