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
      final updatedServices = await repository.getServices();
      _services = updatedServices;
      _lastSync = DateTime.now();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'An unexpected error occurred.';
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
