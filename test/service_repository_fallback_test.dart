import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:statusdesk/models/service.dart';
import 'package:statusdesk/repositories/service_repository.dart';
import 'package:statusdesk/services/cache_service.dart';
import 'package:statusdesk/services/service_api.dart';

class FakeFailingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw const SocketException('Simulated network failure');
  }
}

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp(
      'statusdesk_fallback_test_',
    );

    Hive.init(testDirectory.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ServiceAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await testDirectory.delete(recursive: true);
  });

  test('returns all cached services when API fails', () async {
    final cacheService = CacheService();
    final serviceNames = [
      'GitHub API',
      'FreeOpenAPI',
      'Cloudflare',
      'Test HTTP 200',
      'Test indisponible',
      'FakeStore API',
      'DummyJSON Products',
      'Platzi Fake Store',
    ];

    final cachedServices = serviceNames
        .map(
          (name) => Service(
            name: name,
            status: ServiceStatus.operational,
            responseTime: 120,
            lastChecked: DateTime(2026, 9, 14),
            url: 'https://example.com/$name',
          ),
        )
        .toList();

    await cacheService.saveServices(cachedServices);

    final api = ServiceApi(client: FakeFailingHttpClient());
    final repository = ServiceRepository(api: api, cache: cacheService);

    final services = await repository.getServices();

    expect(services.length, 8);
    expect(services.map((service) => service.name).toSet(),
        equals(serviceNames.toSet()));
  });
}
