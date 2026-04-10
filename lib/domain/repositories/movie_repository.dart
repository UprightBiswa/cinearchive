import '../../core/utils/paginated_response.dart';
import '../entities/app_user.dart';
import '../entities/movie.dart';
import '../entities/movie_bookmark.dart';

abstract class MovieRepository {
  Future<PaginatedResponse<Movie>> fetchMovies({required int page});

  Future<Movie> fetchMovieDetail(String movieId);

  Future<List<MovieBookmark>> getBookmarksForUser(String userLocalId);

  Future<bool> isBookmarked({
    required String userLocalId,
    required String movieId,
  });

  Future<void> toggleBookmark({
    required AppUser user,
    required Movie movie,
  });
}
