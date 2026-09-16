import 'package:hive/hive.dart';

import '../models/history_entry.dart';
import '../models/service.dart';

class CacheService {
  static const String servicesBoxName = 'services';
  static const String _historyBoxName = 'history';

  static Future<Box<Service>> init() async {
    if (Hive.isBoxOpen(servicesBoxName)) return Hive.box<Service>(servicesBoxName);
    return Hive.openBox<Service>(servicesBoxName);
  }

  Future<Box<Service>> _getServicesBox() => init();

  Future<Box<HistoryEntry>> _getHistoryBox() async {
    if (Hive.isBoxOpen(_historyBoxName)) {
      return Hive.box<HistoryEntry>(_historyBoxName);
    }
    return Hive.openBox<HistoryEntry>(_historyBoxName);
  }

  Future<void> saveServices(List<Service> services) async {
    final box = await _getServicesBox();
    final nextNames = services.map((service) => service.name).toSet();
    await box.putAll({for (final service in services) service.name: service});
    final staleKeys = box.keys.where((key) => key is String && !nextNames.contains(key)).toList();
    if (staleKeys.isNotEmpty) await box.deleteAll(staleKeys);
  }

  Future<List<Service>> getCachedServices() async => (await _getServicesBox()).values.toList();

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

  Future<void> clearServices() async => (await _getServicesBox()).clear();
}