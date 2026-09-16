import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';
import '../models/history_entry.dart';

class ServiceRepository {
  final ServiceApi api;
  final CacheService cache;

  ServiceRepository({required this.api, CacheService? cache})
      : cache = cache ?? CacheService();

  static const _expectedServiceNames = {
    'GitHub API',
    'FreeOpenAPI',
    'Cloudflare',
    'Test HTTP 200',
    'Test indisponible',
    'FakeStore API',
    'DummyJSON Products',
    'Platzi Fake Store'
  };

  Future<List<Service>> getServices() async {
    try {
      final liveServices = await api.fetchServices();
      
      if (!_hasCompleteServiceSet(liveServices)) {
        throw StateError('Le monitoring live doit retourner les 8 endpoints configurés.');
      }

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
        if (_hasCompleteServiceSet(cached)) return cached;
      } catch (_) {}
      
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  bool _hasCompleteServiceSet(List<Service> services) {
    final names = services.map((service) => service.name).toSet();
    return names.length == _expectedServiceNames.length &&
        names.containsAll(_expectedServiceNames);
  }
}