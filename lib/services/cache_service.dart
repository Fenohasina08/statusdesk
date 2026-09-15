import 'package:hive/hive.dart';

import '../models/history_entry.dart';
import '../models/service.dart';

class CacheService {
  static const String _servicesBoxName = 'services';
  static const String _historyBoxName = 'history';

  Future<Box<Service>> _getServicesBox() async {
    if (Hive.isBoxOpen(_servicesBoxName)) {
      return Hive.box<Service>(_servicesBoxName);
    }

    return Hive.openBox<Service>(_servicesBoxName);
  }

  Future<Box<HistoryEntry>> _getHistoryBox() async {
    if (Hive.isBoxOpen(_historyBoxName)) {
      return Hive.box<HistoryEntry>(_historyBoxName);
    }

    return Hive.openBox<HistoryEntry>(_historyBoxName);
  }

  Future<void> saveServices(List<Service> services) async {
    final box = await _getServicesBox();

    await box.clear();

    for (final service in services) {
      await box.put(service.name, service);
    }
  }

  Future<List<Service>> getCachedServices() async {
    final box = await _getServicesBox();

    return box.values.toList();
  }

  Future<void> saveHistory(
    String serviceName,
    HistoryEntry entry,
  ) async {
    final box = await _getHistoryBox();

    final key = '${serviceName}_${entry.checkedAt.millisecondsSinceEpoch}';

    await box.put(key, entry);
  }

  Future<List<HistoryEntry>> getHistory(String serviceName) async {
    final box = await _getHistoryBox();

    final prefix = '${serviceName}_';

    return box.keys
        .where((key) => key.toString().startsWith(prefix))
        .map((key) => box.get(key))
        .whereType<HistoryEntry>()
        .toList()
      ..sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
  }

  Future<void> clearHistory() async {
    final box = await _getHistoryBox();

    await box.clear();
  }

  Future<void> clearServices() async {
    final box = await _getServicesBox();

    await box.clear();
  }
}