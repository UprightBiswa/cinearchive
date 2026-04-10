import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/movie_bookmark.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'movie_list_state.dart';

class MovieListCubit extends Cubit<MovieListState> {
  MovieListCubit(this._movieRepository) : super(const MovieListState());

  final MovieRepository _movieRepository;
  AppUser? _user;

  Future<void> initialize(AppUser user) async {
    _user = user;
    await Future.wait(<Future<void>>[
      fetchInitial(),
      loadBookmarks(),
    ]);
  }

  Future<void> fetchInitial() async {
    emit(state.copyWith(isInitialLoading: true, page: 1, clearError: true));

    try {
      final page = await _movieRepository.fetchMovies(page: 1);
      emit(
        state.copyWith(
          movies: page.items,
          page: page.page,
          hasMore: page.hasMore,
          isInitialLoading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isInitialLoading) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final nextPage = state.page + 1;
      final page = await _movieRepository.fetchMovies(page: nextPage);
      emit(
        state.copyWith(
          movies: <Movie>[...state.movies, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadBookmarks() async {
    final user = _user;
    if (user == null) return;

    emit(state.copyWith(isLoadingBookmarks: true, clearError: true));

    try {
      final bookmarks = await _movieRepository.getBookmarksForUser(user.localId);
      final map = <String, bool>{
        for (final MovieBookmark item in bookmarks) item.movieId: true,
      };
      emit(
        state.copyWith(
          savedBookmarks: bookmarks,
          bookmarkMap: map,
          isLoadingBookmarks: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingBookmarks: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> toggleBookmark(Movie movie) async {
    final user = _user;
    if (user == null) return;

    try {
      await _movieRepository.toggleBookmark(user: user, movie: movie);
      await loadBookmarks();
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void selectTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
    if (index == 1) {
      loadBookmarks();
    }
  }
}
