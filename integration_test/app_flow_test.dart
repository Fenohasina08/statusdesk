import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:statusdesk/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Parcours complet : Accueil -> Détail du service -> Test manuel', (WidgetTester tester) async {
    // 1. Lancer l'application principale
    app.main();

    // 2. Attendre activement que les services se chargent (boucle de 10 secondes max)
    bool serviceFound = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
      if (find.text('GitHub API').evaluate().isNotEmpty) {
        serviceFound = true;
        break;
      }
    }
    expect(serviceFound, isTrue, reason: 'Le service "GitHub API" n\'a pas été trouvé après chargement.');

    // 3. Cliquer sur le service pour ouvrir l'écran de détail
    await tester.tap(find.text('GitHub API'));
    await tester.pumpAndSettle();

    // 4. Vérifier qu'on est bien sur l'écran de détail
    expect(find.text('Temps de réponse'), findsOneWidget);

    // 5. Trouver et cliquer sur le bouton d'action ("Tester maintenant")
    // Ce n'est pas un ElevatedButton/TextButton avec un libellé visible,
    // mais un IconButton (le seul présent sur cet écran).
    final testButton = find.byType(IconButton);
    expect(
      testButton,
      findsOneWidget,
      reason: 'Le bouton de test (IconButton) est introuvable sur l\'écran de détail.',
    );
    await tester.tap(testButton);

    // 6. Attendre la fin des opérations asynchrones du test réseau
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 7. Vérifier que l'application est toujours stable et que le bouton est toujours présent
    expect(find.byType(IconButton), findsOneWidget);
  });
}