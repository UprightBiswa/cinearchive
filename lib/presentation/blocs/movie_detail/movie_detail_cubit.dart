import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  MovieDetailCubit(this._movieRepository) : super(const MovieDetailState());

  final MovieRepository _movieRepository;

  Future<void> load(int movieId) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearMovie: true));

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
}
