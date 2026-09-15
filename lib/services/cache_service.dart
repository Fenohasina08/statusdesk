import 'package:hive/hive.dart';

import '../models/service.dart';

class CacheService {
  static const String servicesBoxName = 'services';

  static Future<Box<Service>> init() async {
    if (Hive.isBoxOpen(servicesBoxName)) return Hive.box<Service>(servicesBoxName);
    return Hive.openBox<Service>(servicesBoxName);
  }

  Future<Box<Service>> _getServicesBox() => init();

  Future<void> saveServices(List<Service> services) async {
    final box = await _getServicesBox();
    final nextNames = services.map((service) => service.name).toSet();
    await box.putAll({for (final service in services) service.name: service});
    final staleKeys = box.keys.where((key) => key is String && !nextNames.contains(key)).toList();
    if (staleKeys.isNotEmpty) await box.deleteAll(staleKeys);
  }

  Future<List<Service>> getCachedServices() async => (await _getServicesBox()).values.toList();

  Future<void> clearServices() async => (await _getServicesBox()).clear();
}
