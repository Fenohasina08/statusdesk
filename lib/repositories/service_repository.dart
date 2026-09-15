import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';
import '../models/history_entry.dart';

class ServiceRepository {
  final ServiceApi api;
  final CacheService cache;

  ServiceRepository({required this.api, CacheService? cache})
      : cache = cache ?? CacheService();

  Future<List<Service>> getServices() async {
    try {
      final liveServices = await api.fetchServices();
      try {
        await cache.saveServices(liveServices);
        for (final service in liveServices) {
          final entry = HistoryEntry(
            checkedAt: service.lastChecked,
            responseTime: service.responseTime,
            status: service.status,
          );
          await cache.saveHistory(service.name, entry);
        }
      } catch (_) {}

      return liveServices;
    } catch (error, stackTrace) {
      try {
        final cached = await cache.getCachedServices();
        if (cached.isNotEmpty) return cached;
      } catch (_) {}
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}