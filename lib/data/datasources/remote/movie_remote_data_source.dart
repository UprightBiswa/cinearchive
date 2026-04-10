import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/utils/paginated_response.dart';
import '../../models/movie_model.dart';

class MovieRemoteDataSource {
  MovieRemoteDataSource(this._dio);

  final Dio _dio;

  void _ensureTmdbKey() {
    if (!AppEnv.hasTmdbKey) {
      throw StateError(
        'Missing TMDB_API_KEY. Run with --dart-define=TMDB_API_KEY=your_key',
      );
    }
  }

  Future<PaginatedResponse<MovieModel>> fetchTrendingMovies({
    required int page,
  }) async {
    _ensureTmdbKey();

    final response = await _dio.get<dynamic>(
      '/trending/movie/day',
      queryParameters: <String, dynamic>{
        'language': 'en-US',
        'page': page,
        'api_key': AppEnv.tmdbApiKey,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final movies = (data['results'] as List<dynamic>)
        .map(
          (dynamic item) => MovieModel.fromTmdbJson(item as Map<String, dynamic>),
        )
        .toList();

    return PaginatedResponse<MovieModel>(
      items: movies,
      page: data['page'] as int? ?? page,
      totalPages: data['total_pages'] as int? ?? page,
    );
  }

  Future<MovieModel> fetchMovieDetail(int movieId) async {
    _ensureTmdbKey();

    final response = await _dio.get<dynamic>(
      '/movie/$movieId',
      queryParameters: <String, dynamic>{'api_key': AppEnv.tmdbApiKey},
    );

    return MovieModel.fromTmdbJson(response.data as Map<String, dynamic>);
  }
}
