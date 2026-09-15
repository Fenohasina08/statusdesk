import 'package:hive/hive.dart';

part 'service.g.dart';

@HiveType(typeId: 0)
enum ServiceStatus {
  @HiveField(0)
  operational,

  @HiveField(1)
  degraded,

  @HiveField(2)
  down,

  @HiveField(3)
  unknown,
}

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

@HiveType(typeId: 2)
class Service extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final ServiceStatus status;

  @HiveField(2)
  final int responseTime;

  @HiveField(3)
  final DateTime lastChecked;

  @HiveField(4)
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
      status: serviceStatusFromString(
        json['status'] as String? ?? 'unknown',
      ),
      responseTime: json['responseTime'] as int? ?? 0,
      lastChecked:
          DateTime.tryParse(json['lastChecked'] as String? ?? '') ??
              DateTime.now(),
      url: json['url'] as String? ?? '',
    );
  }
}