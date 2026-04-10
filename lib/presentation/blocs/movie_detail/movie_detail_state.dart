import 'package:equatable/equatable.dart';

import '../../../domain/entities/movie.dart';

class MovieDetailState extends Equatable {
  const MovieDetailState({
    this.isLoading = false,
    this.isBookmarked = false,
    this.movie,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isBookmarked;
  final Movie? movie;
  final String? errorMessage;

  MovieDetailState copyWith({
    bool? isLoading,
    bool? isBookmarked,
    Movie? movie,
    String? errorMessage,
    bool clearMovie = false,
    bool clearError = false,
  }) {
    return MovieDetailState(
      isLoading: isLoading ?? this.isLoading,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      movie: clearMovie ? null : movie ?? this.movie,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, isBookmarked, movie, errorMessage];
}
