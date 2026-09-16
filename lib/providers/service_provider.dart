import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../utils/api_exceptions.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository repository;

  ServiceProvider({required this.repository});

  static const maxHistoryEntries = 10;
  Timer? _pollTimer;
  List<Service> _services = [];
  final Map<String, List<Service>> _history = {};
  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;
  DateTime? _lastSync;

  // Nouveaux états configurables depuis les paramètres
  bool _autoRefreshEnabled = true;
  int _intervalInMinutes = 5;
  bool _offlineModeEnabled = true;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;
  DateTime? get lastSync => _lastSync;
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get intervalInMinutes => _intervalInMinutes;
  bool get offlineModeEnabled => _offlineModeEnabled;

  List<Service> historyFor(String url) =>
      List.unmodifiable(_history[url] ?? const <Service>[]);

  Future<void> initialize() async {
    try {
      final cached = await repository.cache.getCachedServices();
      if (cached.isNotEmpty) {
        _services = cached;
        _recordHistory(cached);
        _lastSync = cached
            .map((service) => service.lastChecked)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        notifyListeners();
      }
    } catch (_) {}
    await fetchServices();
    startPolling();
  }

  // --- Gestion du Polling & Paramètres ---
  void setAutoRefresh(bool enabled) {
    _autoRefreshEnabled = enabled;
    notifyListeners();
    if (_autoRefreshEnabled) {
      startPolling();
    } else {
      stopPolling();
    }
  }

  void setInterval(int minutes) {
    _intervalInMinutes = minutes;
    notifyListeners();
    if (_autoRefreshEnabled) {
      startPolling(); // Redémarre le timer avec le nouvel intervalle
    }
  }

  void setOfflineMode(bool enabled) {
    _offlineModeEnabled = enabled;
    notifyListeners();
  }

  void startPolling() {
    stopPolling();
    if (!_autoRefreshEnabled) return;

    _pollTimer = Timer.periodic(
      Duration(minutes: _intervalInMinutes),
      (_) => fetchServices(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> fetchServices() async {
    if (_isLoading) return;
    _isLoading = true;
    _isPolling = _pollTimer != null;
    _error = null;
    notifyListeners();
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
      _isLoading = false;
      _isPolling = false;
      notifyListeners();
    }
  }

  Future<void> refreshServices() async {
    await fetchServices();
  }

  void _recordHistory(List<Service> services) {
    for (final service in services) {
      final entries = _history.putIfAbsent(service.url, () => <Service>[]);
      entries.removeWhere((entry) => entry.lastChecked == service.lastChecked);
      entries.insert(0, service);
      if (entries.length > maxHistoryEntries) {
        entries.removeRange(maxHistoryEntries, entries.length);
      }
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}