import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink(); // Ne rien afficher si connecté

    return Container(
      width: double.infinity,
      color: const Color(0xffff9800), // Orange d'avertissement
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_off_outlined, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'Mode hors-ligne - Affichage des données en cache',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}