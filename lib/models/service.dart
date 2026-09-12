enum ServiceStatus { operational, degraded, down, unknown }

ServiceStatus serviceStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'operational':
      return ServiceStatus.operational;
    case 'degraded':
      return ServiceStatus.degraded;
    case 'down':
      return ServiceStatus.down;
    default:
      return ServiceStatus.unknown;
  }
}

class Service {
  final String name;
  final ServiceStatus status;
  final int responseTime;  
  final DateTime lastChecked;
  final String url;

  Service({
    required this.name,
    required this.status,
    required this.responseTime,
    required this.lastChecked,
    required this.url,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] as String,
      status: serviceStatusFromString(json['status'] as String? ?? 'unknown'),
      responseTime: json['responseTime'] as int? ?? 0,
      lastChecked: DateTime.tryParse(json['lastChecked'] as String? ?? '') ??
          DateTime.now(),
      url: json['url'] as String? ?? '',
    );
  }
}