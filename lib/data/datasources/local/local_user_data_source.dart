import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/app_user_model.dart';

class LocalUserDataSource {
  Future<Box<String>> _box() async {
    return Hive.isBoxOpen(AppConstants.pendingUsersBox)
        ? Hive.box<String>(AppConstants.pendingUsersBox)
        : Hive.openBox<String>(AppConstants.pendingUsersBox);
  }

  Future<List<AppUserModel>> getPendingUsers() async {
    final box = await _box();
    return box.values.map(AppUserModel.fromRawJson).toList();
  }

  Future<void> upsertUser(AppUserModel user) async {
    final box = await _box();
    await box.put(user.localId, user.toRawJson());
  }

  Future<void> deleteUser(String localId) async {
    final box = await _box();
    await box.delete(localId);
  }
}
