import 'package:hive_flutter/hive_flutter.dart';

import '../../models/history_entry.dart';
import '../../models/service.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ServiceStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ServiceAdapter());
    }

    await Hive.openBox<HistoryEntry>('history');
  }
}