import 'dart:io';

import '../models/service.dart';
import '../services/cache_service.dart';
import '../services/service_api.dart';

/// Couche de données : le réseau est privilégié, Hive garantit une UI utile
/// lorsque l'appareil est hors ligne ou que le monitoring est indisponible.
class ServiceRepository {
  final ServiceApi api;
  final CacheService cache;

  ServiceRepository({required this.api, CacheService? cache})
      : cache = cache ?? CacheService();

  Future<List<Service>> getServices() async {
    try {
      final liveServices = await api.fetchServices();
      await cache.saveServices(liveServices);
      return liveServices;
    } catch (error, stackTrace) {
      // Une erreur réseau ou de transport ne doit pas effacer la dernière vue valide.
      final cached = await cache.getCachedServices();
      if (cached.isNotEmpty) return cached;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
