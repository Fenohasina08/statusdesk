import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';

/// Couche réseau puis cache : une erreur Hive ne masque jamais une réponse live.
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
      } catch (_) {
        // Le cache est secondaire : l'interface doit quand même afficher le live.
      }
      return liveServices;
    } catch (error, stackTrace) {
      try {
        final cached = await cache.getCachedServices();
        if (cached.isNotEmpty) return cached;
      } catch (_) {
        // Continue avec l'erreur réseau originale si Hive est indisponible.
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
