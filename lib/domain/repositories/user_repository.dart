import '../../core/utils/paginated_response.dart';
import '../entities/app_user.dart';

abstract class UserRepository {
  Future<PaginatedResponse<AppUser>> fetchUsers({required int page});

  Future<AppUser> createUser({
    required String name,
    required String job,
  });

  Future<List<AppUser>> getPendingUsers();

  Future<void> syncPendingUsersAndBookmarks();
}
