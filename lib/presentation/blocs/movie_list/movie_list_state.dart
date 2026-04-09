import 'package:equatable/equatable.dart';

import '../../../domain/entities/movie.dart';

class MovieListState extends Equatable {
  const MovieListState({
    this.movies = const <Movie>[],
    this.page = 1,
    this.hasMore = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Movie> movies;
  final int page;
  final bool hasMore;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  MovieListState copyWith({
    List<Movie>? movies,
    int? page,
    bool? hasMore,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        movies,
        page,
        hasMore,
        isInitialLoading,
        isLoadingMore,
        errorMessage,
      ];
}
