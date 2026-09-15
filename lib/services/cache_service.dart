import 'package:hive/hive.dart';

import '../models/service.dart';

class CacheService {
  static const String _servicesBoxName = 'services';

  Future<Box<Service>> _getServicesBox() async {
    if (Hive.isBoxOpen(_servicesBoxName)) {
      return Hive.box<Service>(_servicesBoxName);
    }

    return Hive.openBox<Service>(_servicesBoxName);
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

  Future<void> clearServices() async {
    final box = await _getServicesBox();

    await box.clear();
  }
}