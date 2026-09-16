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
            api: ServiceApi(),
          ),
        ),
        child: const MyApp(),
      ),
    );

    expect(find.text('StatusDesk'), findsOneWidget);
    expect(find.text('Etat des services'), findsOneWidget);
    expect(find.text('Foundations ready ✅ — Dashboard coming soon'), findsOneWidget);
  });
}
