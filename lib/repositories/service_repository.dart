import '../models/service.dart';
import '../services/service_api.dart';

class ServiceRepository {
  final ServiceApi api;
  ServiceRepository({required this.api});

  Future<List<Service>> getServices() {
    return api.fetchServices();
  }
}