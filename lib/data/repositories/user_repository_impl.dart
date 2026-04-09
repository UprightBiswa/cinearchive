import 'package:flutter/foundation.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/utils/paginated_response.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/local_bookmark_data_source.dart';
import '../datasources/local/local_user_data_source.dart';
import '../datasources/remote/user_remote_data_source.dart';
import '../models/app_user_model.dart';
import '../models/movie_bookmark_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required LocalUserDataSource localUserDataSource,
    required LocalBookmarkDataSource localBookmarkDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localUserDataSource = localUserDataSource,
        _localBookmarkDataSource = localBookmarkDataSource,
        _connectivityService = connectivityService;

  final UserRemoteDataSource _remoteDataSource;
  final LocalUserDataSource _localUserDataSource;
  final LocalBookmarkDataSource _localBookmarkDataSource;
  final ConnectivityService _connectivityService;

  @override
  Future<PaginatedResponse<AppUser>> fetchUsers({required int page}) async {
    final remotePage = await _remoteDataSource.fetchUsers(page: page);
    final pendingUsers = await _localUserDataSource.getPendingUsers();

    if (page == 1 && pendingUsers.isNotEmpty) {
      return PaginatedResponse<AppUser>(
        items: <AppUser>[...pendingUsers, ...remotePage.items],
        page: remotePage.page,
        totalPages: remotePage.totalPages,
      );
    }

    return PaginatedResponse<AppUser>(
      items: remotePage.items,
      page: remotePage.page,
      totalPages: remotePage.totalPages,
    );
  }

  @override
  Future<AppUser> createUser({
    required String name,
    required String job,
  }) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final online = await _connectivityService.isOnline;

    if (online) {
      return _remoteDataSource.createUser(localId: localId, name: name, job: job);
    }

    final localUser = AppUserModel(
      localId: localId,
      name: name,
      job: job,
      createdAt: DateTime.now(),
      isPendingSync: true,
    );
    await _localUserDataSource.upsertUser(localUser);
    return localUser;
  }

  @override
  Future<List<AppUser>> getPendingUsers() async {
    return _localUserDataSource.getPendingUsers();
  }

  @override
  Future<void> syncPendingUsersAndBookmarks() async {
    final online = await _connectivityService.isOnline;
    if (!online) return;

    final users = await _localUserDataSource.getPendingUsers();
    final bookmarks = await _localBookmarkDataSource.getBookmarks();

    for (final user in users) {
      try {
        final remoteUser = await _remoteDataSource.createUser(
          localId: user.localId,
          name: user.name,
          job: user.job,
        );

        final linkedBookmarks = bookmarks
            .where((bookmark) => bookmark.userLocalId == user.localId)
            .toList();

        for (final bookmark in linkedBookmarks) {
          final updatedBookmark = MovieBookmarkModel(
            id: bookmark.id,
            userLocalId: bookmark.userLocalId,
            userRemoteId: remoteUser.remoteId,
            movieId: bookmark.movieId,
            title: bookmark.title,
            posterPath: bookmark.posterPath,
            releaseDate: bookmark.releaseDate,
            isPendingSync: false,
          );
          await _localBookmarkDataSource.upsertBookmark(updatedBookmark);
        }

        await _localUserDataSource.deleteUser(user.localId);
      } catch (error, stackTrace) {
        debugPrint('Sync failed for ${user.localId}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
