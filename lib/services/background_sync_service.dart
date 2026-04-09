import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../core/constants/app_constants.dart';
import '../core/di/injection_container.dart';
import '../domain/repositories/user_repository.dart';

class BackgroundSyncService {
  const BackgroundSyncService._();

  static Future<void> initialize() async {
    Workmanager().registerPeriodicTask(
      AppConstants.syncUsersTask,
      AppConstants.syncUsersTask,
      frequency: AppConstants.syncFrequency,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
    await initializeDependencies();
    await sl<UserRepository>().syncPendingUsersAndBookmarks();

    return Future<bool>.value(true);
  });
}
