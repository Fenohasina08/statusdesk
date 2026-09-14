import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';

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

      // Si l'API fonctionne, on met à jour le cache.
      await cache.saveServices(services);

      return services;
    } catch (_) {
      // Si l'API échoue, on utilise les données locales.
      final cachedServices = await cache.getCachedServices();

      if (cachedServices.isNotEmpty) {
        return cachedServices;
      }

      // Aucun cache disponible : on laisse l'erreur remonter.
      rethrow;
    }
  }
}