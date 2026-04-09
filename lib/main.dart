import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'core/di/injection_container.dart';
import 'presentation/app/cine_archive_app.dart';
import 'services/background_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDirectory.path);
  await initializeDependencies();
  await Workmanager().initialize(callbackDispatcher);
  await BackgroundSyncService.initialize();

  runApp(const CineArchiveApp());
}
