import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/main.dart';
import 'package:statusdesk/models/service.dart';
import 'package:statusdesk/pages/dashboard_screen.dart';
import 'package:statusdesk/providers/locale_provider.dart';
import 'package:statusdesk/providers/service_provider.dart';
import 'package:statusdesk/providers/theme_provider.dart';
import 'package:statusdesk/repositories/service_repository.dart';
import 'package:statusdesk/services/service_api.dart';

class FakeServiceRepository extends ServiceRepository {
  FakeServiceRepository() : super(api: ServiceApi());

  @override
  Future<List<Service>> getServices() async => <Service>[];
}

void main() {
  testWidgets('StatusDesk affiche le dashboard actuel',
      (WidgetTester tester) async {
    final themeNotifier = ThemeNotifier();

    // Client HTTP factice : répond systématiquement 200, évite les vraies
    // requêtes réseau (bloquées par TestWidgetsFlutterBinding) pendant les
    // tests, et rend le comportement "isOffline" déterministe.
    final fakeHttpClient = MockClient((request) async {
      return http.Response('', 200);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeNotifier),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
          ChangeNotifierProvider(
            create: (_) => ServiceProvider(
              repository: FakeServiceRepository(),
              httpClient: fakeHttpClient,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Laisse les futures du provider (checkConnectivity, fetchServices,
    // vérification internet) se résoudre avant de vérifier l'arbre de widgets.
    await tester.pumpAndSettle();

    // Correction : Utilisation d'éléments sûrs et présents dans l'arbre de widgets
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Accueil'), findsWidgets);
  });
}