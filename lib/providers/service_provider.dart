import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../utils/api_exceptions.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository repository;
  final http.Client _httpClient;

  ServiceProvider({
    required this.repository,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client() {
    _initConnectivity();
  }

  static const maxHistoryEntries = 10;
  Timer? _pollTimer;
  List<Service> _services = [];
  final Map<String, List<Service>> _history = {};
  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;
  DateTime? _lastSync;

  // Paramètres configurables
  bool _autoRefreshEnabled = true;
  int _intervalInMinutes = 5;
  bool _offlineModeEnabled = false;

  // Détection automatique du réseau
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _connectivityPollTimer;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;
  DateTime? get lastSync => _lastSync;
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get intervalInMinutes => _intervalInMinutes;
  bool get offlineModeEnabled => _offlineModeEnabled;
  bool get isOffline => _isOffline;

  List<Service> historyFor(String url) =>
      List.unmodifiable(_history[url] ?? const <Service>[]);

  // --- Détection réseau ---

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await Connectivity().checkConnectivity();
      await _updateConnectionStatus(connectivityResult);
    } catch (e) {
      if (kDebugMode) {
        print('[Connectivity] Erreur checkConnectivity initial: $e');
      }
    }

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (kDebugMode) {
        print('[Connectivity] onConnectivityChanged déclenché: $result');
      }
      _updateConnectionStatus(result);
    });

    // Filet de sécurité : sur desktop natif, l'interface peut rester "up"
    // (Docker, VPN, bridges) sans accès internet réel, et l'OS ne redéclenche
    // pas toujours onConnectivityChanged. On revérifie donc périodiquement.
    _connectivityPollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) async {
        final result = await Connectivity().checkConnectivity();
        if (kDebugMode) {
          print('[Connectivity] Poll périodique -> $result');
        }
        await _updateConnectionStatus(result);
      },
    );
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final bool interfaceDown =
        result.isEmpty || result.every((r) => r == ConnectivityResult.none);

    if (kDebugMode) {
      print('[Connectivity] Interfaces détectées: $result | interfaceDown=$interfaceDown');
    }

    if (interfaceDown) {
      _setOffline(true);
      return;
    }

    final bool hasRealInternet = await _hasInternetAccess();
    if (kDebugMode) {
      print('[Connectivity] hasRealInternet=$hasRealInternet');
    }
    _setOffline(!hasRealInternet);
  }

  /// Vérifie un vrai accès internet (au-delà du simple état d'interface).
  /// Sur le web, les requêtes cross-origin sont bloquées par CORS pour la
  /// quasi-totalité des domaines externes : on se fie donc à l'état fourni
  /// par connectivity_plus (navigator.onLine), déjà vérifié juste avant.
  /// Sur desktop/mobile, on confirme avec une vraie requête HTTP, car
  /// l'interface peut être "up" (Docker/VPN/bridge) sans accès réel.
  Future<bool> _hasInternetAccess() async {
    if (kIsWeb) {
      return true;
    }

    try {
      final response = await _httpClient
          .get(Uri.parse('https://www.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('[Connectivity] Requête échouée: $e');
      }
      return false;
    }
  }

  void _setOffline(bool value) {
    if (_isOffline != value) {
      if (kDebugMode) {
        print('[Connectivity] Changement état -> isOffline: $_isOffline -> $value');
      }
      _isOffline = value;
      notifyListeners();
    }
  }

  // --- Initialisation & récupération des services ---

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
      startPolling();
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
    _connectivitySubscription?.cancel();
    _connectivityPollTimer?.cancel();
    stopPolling();
    _httpClient.close();
    super.dispose();
  }
}