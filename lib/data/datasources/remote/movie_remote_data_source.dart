import 'package:dio/dio.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/paginated_response.dart';
import '../../models/movie_model.dart';

class MovieRemoteDataSource {
  MovieRemoteDataSource(this._dio);

  final Dio _dio;

  void _ensureOmdbKey() {
    if (!AppEnv.hasOmdbKey) {
      throw StateError(
        'Missing OMDB_API_KEY. Create one at https://www.omdbapi.com/apikey.aspx and run with --dart-define=OMDB_API_KEY=your_key',
      );
    }
  }

  Future<PaginatedResponse<MovieModel>> fetchTrendingMovies({
    required int page,
  }) async {
    _ensureOmdbKey();

    final response = await _safeGet(
      queryParameters: <String, dynamic>{
        'apikey': AppEnv.omdbApiKey,
        's': AppConstants.omdbSearchQuery,
        'type': 'movie',
        'page': page,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['Response'] == 'False') {
      throw StateError(data['Error'] as String? ?? 'Unable to load movies from OMDB');
    }

    final searchResults = data['Search'] as List<dynamic>? ?? <dynamic>[];
    final movies = searchResults
        .map(
          (dynamic item) => MovieModel.fromOmdbSearchJson(item as Map<String, dynamic>),
        )
        .toList();

    final totalResults = int.tryParse(data['totalResults'] as String? ?? '') ?? movies.length;
    final totalPages = (totalResults / 10).ceil().clamp(1, 1000);

    return PaginatedResponse<MovieModel>(
      items: movies,
      page: page,
      totalPages: totalPages,
    );
  }

  Future<MovieModel> fetchMovieDetail(String movieId) async {
    _ensureOmdbKey();

    final response = await _safeGet(
      queryParameters: <String, dynamic>{
        'apikey': AppEnv.omdbApiKey,
        'i': movieId,
        'plot': 'full',
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['Response'] == 'False') {
      throw StateError(data['Error'] as String? ?? 'Unable to load movie details from OMDB');
    }

    return MovieModel.fromOmdbDetailJson(data);
  }

  Future<Response<dynamic>> _safeGet({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      return await _dio.get<dynamic>(
        '/',
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw StateError(
          'OMDB returned 401 Unauthorized. Your key may not be activated yet. Open the activation link from the OMDB email, then try again.',
        );
      }
      rethrow;
    }
  }
}
