import 'package:equatable/equatable.dart';

import '../../../domain/entities/movie.dart';
import '../../../domain/entities/movie_bookmark.dart';

class MovieListState extends Equatable {
  const MovieListState({
    this.movies = const <Movie>[],
    this.savedBookmarks = const <MovieBookmark>[],
    this.bookmarkMap = const <String, bool>{},
    this.selectedTabIndex = 0,
    this.page = 1,
    this.hasMore = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isLoadingBookmarks = false,
    this.errorMessage,
  });

  final List<Movie> movies;
  final List<MovieBookmark> savedBookmarks;
  final Map<String, bool> bookmarkMap;
  final int selectedTabIndex;
  final int page;
  final bool hasMore;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isLoadingBookmarks;
  final String? errorMessage;

  MovieListState copyWith({
    List<Movie>? movies,
    List<MovieBookmark>? savedBookmarks,
    Map<String, bool>? bookmarkMap,
    int? selectedTabIndex,
    int? page,
    bool? hasMore,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isLoadingBookmarks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      savedBookmarks: savedBookmarks ?? this.savedBookmarks,
      bookmarkMap: bookmarkMap ?? this.bookmarkMap,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingBookmarks: isLoadingBookmarks ?? this.isLoadingBookmarks,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        movies,
        savedBookmarks,
        bookmarkMap,
        selectedTabIndex,
        page,
        hasMore,
        isInitialLoading,
        isLoadingMore,
        isLoadingBookmarks,
        errorMessage,
      ];
}
