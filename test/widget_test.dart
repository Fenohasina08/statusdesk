// Test de fumée basique pour l'app StatusDesk.
//
// Vérifie que l'app démarre correctement et affiche le placeholder
// du tableau de bord (AppBar "StatusDesk" + message d'accueil).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/main.dart';
import 'package:statusdesk/providers/service_provider.dart';
import 'package:statusdesk/repositories/service_repository.dart';
import 'package:statusdesk/services/service_api.dart';

void main() {
  testWidgets('StatusDesk affiche l\'AppBar et le placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ServiceProvider(
          repository: ServiceRepository(
            api: ServiceApi(baseUrl: 'https://ton-api.example.com'),
          ),
        ),
        child: const MyApp(),
      ),
    );

    // Le titre de l'AppBar est bien affiché.
    expect(find.text('StatusDesk'), findsOneWidget);
    expect(find.text('Etat des services'), findsOneWidget);

    // Le message placeholder du body est présent.
    expect(find.text('Foundations ready ✅ — Dashboard coming soon'), findsOneWidget);
  });
}