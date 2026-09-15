import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../utils/api_exceptions.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository repository;
  ServiceProvider({required this.repository});

  static const pollingInterval = Duration(seconds: 15);
  Timer? _pollTimer;
  List<Service> _services = [];
  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;
  DateTime? _lastSync;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;
  DateTime? get lastSync => _lastSync;

  Future<void> initialize() async {
    try {
      final cached = await repository.cache.getCachedServices();
      if (cached.isNotEmpty) {
        _services = cached;
        _lastSync = cached.map((service) => service.lastChecked).reduce((a, b) => a.isAfter(b) ? a : b);
        notifyListeners();
      }
    } catch (_) {
      // Live polling remains available if Hive cannot be read.
    }
    await fetchServices();
  }

  void startPolling() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(pollingInterval, (_) => fetchServices());
  }

  Future<void> fetchServices() async {
    if (_isLoading) return;
    _isLoading = true;
    _isPolling = _pollTimer != null;
    _error = null;
    notifyListeners();
    try {
      _services = await repository.getServices();
      _lastSync = DateTime.now();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Mode hors connexion : dernières données conservées.';
    } finally {
      _isLoading = false;
      _isPolling = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }
}
