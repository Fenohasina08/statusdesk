import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../utils/api_exceptions.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository repository;
  ServiceProvider({required this.repository});
  static const pollingInterval = Duration(seconds: 15);
  static const maxHistoryEntries = 10;
  Timer? _pollTimer;
  List<Service> _services = [];
  final Map<String, List<Service>> _history = {};
  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;
  DateTime? _lastSync;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;
  DateTime? get lastSync => _lastSync;
  List<Service> historyFor(String url) => List.unmodifiable(_history[url] ?? const <Service>[]);

  Future<void> initialize() async {
    try {
      final cached = await repository.cache.getCachedServices();
      if (cached.isNotEmpty) {
        _services = cached;
        _recordHistory(cached);
        _lastSync = cached.map((service) => service.lastChecked).reduce((a, b) => a.isAfter(b) ? a : b);
        notifyListeners();
      }
    } catch (_) {}
    await fetchServices();
  }

  void startPolling() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(pollingInterval, (_) => fetchServices());
  }

  Future<void> fetchServices() async {
    if (_isLoading) return;
    _isLoading = true; _isPolling = _pollTimer != null; _error = null; notifyListeners();
    try {
      final updated = await repository.getServices();
      _services = updated;
      _recordHistory(updated);
      _lastSync = DateTime.now();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Mode hors connexion : dernières données conservées.';
    } finally {
      _isLoading = false; _isPolling = false; notifyListeners();
    }
  }

  void _recordHistory(List<Service> services) {
    for (final service in services) {
      final entries = _history.putIfAbsent(service.url, () => <Service>[]);
      entries.removeWhere((entry) => entry.lastChecked == service.lastChecked);
      entries.insert(0, service);
      if (entries.length > maxHistoryEntries) entries.removeRange(maxHistoryEntries, entries.length);
    }
  }

  @override
  void dispose() { _pollTimer?.cancel(); _pollTimer = null; super.dispose(); }
}
