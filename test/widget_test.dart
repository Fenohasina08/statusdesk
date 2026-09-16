import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/main.dart';
import 'package:statusdesk/models/service.dart';
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeNotifier),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
          ChangeNotifierProvider(
            create: (_) => ServiceProvider(
              repository: FakeServiceRepository(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // 'StatusDesk' est présent dans l'AppBar et dans l'Accueil (2 fois)
    expect(find.text('StatusDesk'), findsNWidgets(2));
    
    // 'Services' est présent dans le titre de la section Accueil et dans la BottomNavigationBar (2 fois)
    expect(find.text('Services'), findsNWidgets(2));

    await tester.pump();
  });
}