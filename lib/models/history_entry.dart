import 'package:hive/hive.dart';

import 'service.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final DateTime checkedAt;

  @HiveField(1)
  final int responseTime;

  @HiveField(2)
  final ServiceStatus status;

  HistoryEntry({
    required this.checkedAt,
    required this.responseTime,
    required this.status,
  });
}