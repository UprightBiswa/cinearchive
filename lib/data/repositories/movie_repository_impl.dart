import '../../core/network/connectivity_service.dart';
import '../../core/utils/paginated_response.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_bookmark.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/local/local_bookmark_data_source.dart';
import '../datasources/remote/movie_remote_data_source.dart';
import '../models/movie_bookmark_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required MovieRemoteDataSource remoteDataSource,
    required LocalBookmarkDataSource localBookmarkDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localBookmarkDataSource = localBookmarkDataSource,
        _connectivityService = connectivityService;

  final MovieRemoteDataSource _remoteDataSource;
  final LocalBookmarkDataSource _localBookmarkDataSource;
  final ConnectivityService _connectivityService;

  @override
  Future<PaginatedResponse<Movie>> fetchMovies({required int page}) {
    return _remoteDataSource.fetchTrendingMovies(page: page);
  }

  @override
  Future<Movie> fetchMovieDetail(String movieId) {
    return _remoteDataSource.fetchMovieDetail(movieId);
  }

  @override
  Future<List<MovieBookmark>> getBookmarksForUser(String userLocalId) async {
    final bookmarks = await _localBookmarkDataSource.getBookmarks();
    return bookmarks.where((item) => item.userLocalId == userLocalId).toList();
  }

  @override
  Future<bool> isBookmarked({
    required String userLocalId,
    required String movieId,
  }) async {
    final bookmarks = await _localBookmarkDataSource.getBookmarks();
    return bookmarks.any(
      (item) => item.userLocalId == userLocalId && item.movieId == movieId,
    );
  }

  @override
  Future<void> toggleBookmark({
    required AppUser user,
    required Movie movie,
  }) async {
    final isOnline = await _connectivityService.isOnline;
    final bookmarks = await _localBookmarkDataSource.getBookmarks();
    final existing = bookmarks.where(
      (item) => item.userLocalId == user.localId && item.movieId == movie.id,
    );

    if (existing.isNotEmpty) {
      await _localBookmarkDataSource.deleteBookmark(existing.first.id);
      return;
    }

    final bookmark = MovieBookmarkModel(
      id: 'bookmark_${user.localId}_${movie.id}',
      userLocalId: user.localId,
      userRemoteId: user.remoteId,
      movieId: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      isPendingSync: !isOnline || user.remoteId == null,
    );

    await _localBookmarkDataSource.upsertBookmark(bookmark);
  }
}
