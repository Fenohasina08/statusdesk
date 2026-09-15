import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';

/// Réseau prioritaire, avec un cache de secours uniquement s'il est complet.
class ServiceRepository {
  final ServiceApi api;
  final CacheService cache;
  ServiceRepository({required this.api, CacheService? cache}) : cache = cache ?? CacheService();

  static const _expectedServiceNames = {'GitHub API', 'FreeOpenAPI', 'Cloudflare', 'Test HTTP 200', 'Test indisponible'};

  Future<List<Service>> getServices() async {
    try {
      final liveServices = await api.fetchServices();
      if (!_hasCompleteServiceSet(liveServices)) throw StateError('Le monitoring live doit retourner les 5 endpoints configurés.');
      try {
        await cache.saveServices(liveServices);
      } catch (_) {
        // Le cache est secondaire : le résultat live reste prioritaire.
      }
      return liveServices;
    } catch (error, stackTrace) {
      try {
        final cached = await cache.getCachedServices();
        if (_hasCompleteServiceSet(cached)) return cached;
      } catch (_) {
        // Continue avec l’erreur originale si Hive est indisponible.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  bool _hasCompleteServiceSet(List<Service> services) {
    final names = services.map((service) => service.name).toSet();
    return names.length == _expectedServiceNames.length && names.containsAll(_expectedServiceNames);
  }
}
