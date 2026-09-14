import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../lib/models/service.dart';
import '../lib/services/cache_service.dart';

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp('statusdesk_test_');

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

  test('saveServices and getCachedServices work correctly', () async {
    final cacheService = CacheService();

    final service = Service(
      name: 'GitHub',
      status: ServiceStatus.operational,
      responseTime: 120,
      lastChecked: DateTime(2026, 9, 14, 19, 0),
      url: 'https://github.com',
    );

    await cacheService.saveServices([service]);

    final cachedServices = await cacheService.getCachedServices();

    expect(cachedServices.length, 1);
    expect(cachedServices.first.name, 'GitHub');
    expect(cachedServices.first.status, ServiceStatus.operational);
    expect(cachedServices.first.responseTime, 120);
    expect(cachedServices.first.url, 'https://github.com');
  });
}