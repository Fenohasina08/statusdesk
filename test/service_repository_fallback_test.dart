import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:statusdesk/models/service.dart';
import 'package:statusdesk/repositories/service_repository.dart';
import 'package:statusdesk/services/cache_service.dart';
import 'package:statusdesk/services/service_api.dart';

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

  test('returns cached services when API fails', () async {
    final cacheService = CacheService();

    final cachedService = Service(
      name: 'GitHub',
      status: ServiceStatus.operational,
      responseTime: 120,
      lastChecked: DateTime(2026, 9, 14),
      url: 'https://github.com',
    );

    // On prépare le cache.
    await cacheService.saveServices([cachedService]);

    // URL volontairement invalide pour provoquer une erreur réseau.
    final api = ServiceApi(
      baseUrl: 'http://127.0.0.1:59999',
    );

    final repository = ServiceRepository(
      api: api,
      cache: cacheService,
    );

    final services = await repository.getServices();

    expect(services.length, 1);
    expect(services.first.name, 'GitHub');
    expect(services.first.status, ServiceStatus.operational);
    expect(services.first.responseTime, 120);
  });
}