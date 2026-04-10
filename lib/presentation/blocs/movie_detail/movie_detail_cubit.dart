import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  MovieDetailCubit(this._movieRepository) : super(const MovieDetailState());

  final MovieRepository _movieRepository;
  AppUser? _user;

  Future<void> initialize({
    required AppUser user,
    required String movieId,
    Movie? initialMovie,
  }) async {
    _user = user;
    if (initialMovie != null) {
      emit(state.copyWith(movie: initialMovie, clearError: true));
    }
    await Future.wait(<Future<void>>[
      load(movieId),
      loadBookmarkStatus(movieId),
    ]);
  }

  Future<void> load(String movieId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final movie = await _movieRepository.fetchMovieDetail(movieId);
      emit(
        state.copyWith(
          isLoading: false,
          movie: movie,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadBookmarkStatus(String movieId) async {
    final user = _user;
    if (user == null) return;

    try {
      final isBookmarked = await _movieRepository.isBookmarked(
        userLocalId: user.localId,
        movieId: movieId,
      );
      emit(state.copyWith(isBookmarked: isBookmarked, clearError: true));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> toggleBookmark(Movie movie) async {
    final user = _user;
    if (user == null) return;

    try {
      await _movieRepository.toggleBookmark(user: user, movie: movie);
      emit(state.copyWith(isBookmarked: !state.isBookmarked, clearError: true));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
