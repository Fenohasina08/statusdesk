import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';
import '../models/history_entry.dart';

class ServiceRepository {
  final ServiceApi api;
  final CacheService cache;

  ServiceRepository({
    required this.api,
    required this.cache,
  });

  Future<List<Service>> getServices() async {
  try {
    final services = await api.fetchServices();

    await cache.saveServices(services);

    for (final service in services) {
      final entry = HistoryEntry(
        checkedAt: service.lastChecked,
        responseTime: service.responseTime,
        status: service.status,
      );

      await cache.saveHistory(service.name, entry);
    }

    return services;
  } catch (_) {
    final cachedServices = await cache.getCachedServices();

    if (cachedServices.isNotEmpty) {
      return cachedServices;
    }

    rethrow;
  }
}
}