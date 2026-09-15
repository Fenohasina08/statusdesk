import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:statusdesk/models/history_entry.dart';
import 'package:statusdesk/models/service.dart';
import 'package:statusdesk/services/cache_service.dart';

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp(
      'statusdesk_history_test_',
    );

    Hive.init(testDirectory.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    await testDirectory.delete(recursive: true);
  });

  test('saves and retrieves service history', () async {
    final cacheService = CacheService();

    final firstEntry = HistoryEntry(
      checkedAt: DateTime(2026, 9, 15, 10, 0),
      responseTime: 120,
      status: ServiceStatus.operational,
    );

    final secondEntry = HistoryEntry(
      checkedAt: DateTime(2026, 9, 15, 10, 5),
      responseTime: 450,
      status: ServiceStatus.degraded,
    );

    await cacheService.saveHistory('GitHub', firstEntry);
    await cacheService.saveHistory('GitHub', secondEntry);

    final history = await cacheService.getHistory('GitHub');

    expect(history.length, 2);
    expect(history.first.status, ServiceStatus.degraded);
    expect(history.first.responseTime, 450);
    expect(history.last.status, ServiceStatus.operational);
    expect(history.last.responseTime, 120);
  });
}