import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:statusdesk/main.dart';
import 'package:statusdesk/providers/service_provider.dart';
import 'package:statusdesk/repositories/service_repository.dart';
import 'package:statusdesk/services/service_api.dart';

class FakeFailingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw const SocketException('Simulated network failure');
  }
}

void main() {
  testWidgets('StatusDesk affiche le dashboard actuel',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ServiceProvider(
          repository: ServiceRepository(
            api: ServiceApi(client: FakeFailingHttpClient()),
          ),
        ),
        child: const MyApp(),
      ),
    );

    expect(find.text('StatusDesk'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);

    await tester.pump();
  });
}
