import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:statusdesk/main.dart';
import 'package:statusdesk/models/service.dart';
import 'package:statusdesk/providers/service_provider.dart';
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
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ServiceProvider(
          repository: FakeServiceRepository(),
        ),
        child: const MyApp(),
      ),
    );

    expect(find.text('StatusDesk'), findsOneWidget);
    expect(find.text('Services'), findsNWidgets(2));

    await tester.pump();
  });
}
