import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/service.dart';

class ServiceApi {
  final Duration timeout;
  final http.Client _client;
  ServiceApi({Duration? timeout, http.Client? client}) : timeout = timeout ?? const Duration(seconds: 30), _client = client ?? http.Client();

  static const monitoredEndpoints = <_MonitoredEndpoint>[
    _MonitoredEndpoint('GitHub API', 'https://api.github.com'),
    _MonitoredEndpoint('FreeOpenAPI', 'https://freeopenapi.dev'),
    _MonitoredEndpoint('Cloudflare', 'https://www.cloudflare.com'),
    _MonitoredEndpoint('Test HTTP 200', 'https://httpbin.org/status/200'),
    _MonitoredEndpoint('Test indisponible', 'https://httpbin.org/status/503'),
    _MonitoredEndpoint('FakeStore API', 'https://fakestoreapi.com/products'),
    _MonitoredEndpoint('DummyJSON Products', 'https://dummyjson.com/products'),
    _MonitoredEndpoint('Platzi Fake Store', 'https://api.escuelajs.co/api/v1/products'),
  ];

  Future<List<Service>> fetchServices() async => Future.wait(monitoredEndpoints.map(_probe));
  Future<Service> _probe(_MonitoredEndpoint endpoint) async { final stopwatch = Stopwatch()..start(); try { final response = await _client.get(Uri.parse(endpoint.url), headers: const {'Accept': '*/*', 'User-Agent': 'StatusDesk-monitor/1.0'}).timeout(timeout); stopwatch.stop(); final latency = stopwatch.elapsedMilliseconds; return Service(name: endpoint.name, status: _statusFor(response.statusCode, latency), responseTime: latency, lastChecked: DateTime.now(), url: endpoint.url); } on TimeoutException { stopwatch.stop(); return _failed(endpoint, stopwatch.elapsedMilliseconds); } on SocketException { stopwatch.stop(); return _failed(endpoint, stopwatch.elapsedMilliseconds); } catch (_) { stopwatch.stop(); return _failed(endpoint, stopwatch.elapsedMilliseconds); } }
  ServiceStatus _statusFor(int code, int latency) { if (code >= 500) return ServiceStatus.down; if (code >= 200 && code < 300 && latency < 800) return ServiceStatus.operational; if (code >= 400 || latency >= 800) return ServiceStatus.degraded; return ServiceStatus.degraded; }
  Service _failed(_MonitoredEndpoint endpoint, int latency) => Service(name: endpoint.name, status: ServiceStatus.down, responseTime: latency, lastChecked: DateTime.now(), url: endpoint.url);
  void close() => _client.close();
}
class _MonitoredEndpoint { final String name; final String url; const _MonitoredEndpoint(this.name, this.url); }
