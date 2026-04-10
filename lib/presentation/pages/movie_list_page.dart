import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_bookmark.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/movie_list/movie_list_cubit.dart';
import '../blocs/movie_list/movie_list_state.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/movie_tile.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({
    required this.user,
    super.key,
  });

  final AppUser user;

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final ScrollController _scrollController = ScrollController();
  final MovieRepository _movieRepository = sl<MovieRepository>();
  final Map<int, bool> _bookmarkState = <int, bool>{};
  int _currentIndex = 0;
  bool _isLoadingBookmarks = true;
  List<MovieBookmark> _savedBookmarks = const <MovieBookmark>[];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _movieRepository.getBookmarksForUser(widget.user.localId);
    if (!mounted) return;
    setState(() {
      _savedBookmarks = bookmarks;
      _bookmarkState
        ..clear()
        ..addEntries(bookmarks.map((item) => MapEntry(item.movieId, true)));
      _isLoadingBookmarks = false;
    });
  }

  void _onScroll() {
    if (_currentIndex != 0 || !_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      context.read<MovieListCubit>().fetchMore();
    }
  }

  Future<void> _toggleBookmark(Movie movie) async {
    await _movieRepository.toggleBookmark(user: widget.user, movie: movie);
    await _loadBookmarks();
  }

  Future<void> _openMovieDetail(Movie movie) async {
    await context.push(
      '/movie-detail',
      extra: <String, dynamic>{
        'movieId': movie.id,
        'movie': movie,
        'user': widget.user,
      },
    );
    await _loadBookmarks();
  }

  Widget _buildTrendingTab(MovieListState state) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.movies.isEmpty) {
      return Center(
        child: FilledButton(
          onPressed: () => context.read<MovieListCubit>().fetchInitial(),
          child: const Text('Retry loading movies'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MovieListCubit>().fetchInitial(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.movies.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final movie = state.movies[index];
          return MovieTile(
            movie: movie,
            trailing: BookmarkButton(
              isBookmarked: _bookmarkState[movie.id] ?? false,
              onPressed: () => _toggleBookmark(movie),
            ),
            onTap: () => _openMovieDetail(movie),
          );
        },
      ),
    );
  }

  Widget _buildSavedTab() {
    if (_isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedBookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No saved movies yet for ${widget.user.fullName}. Bookmark from the Trending tab and they will appear here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedBookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = _savedBookmarks[index];
          final movie = Movie(
            id: bookmark.movieId,
            title: bookmark.title,
            posterPath: bookmark.posterPath,
            overview: '',
            releaseDate: bookmark.releaseDate,
          );

          return MovieTile(
            movie: movie,
            trailing: BookmarkButton(
              isBookmarked: true,
              onPressed: () => _toggleBookmark(movie),
            ),
            onTap: () => _openMovieDetail(movie),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.fullName.isEmpty ? 'Movies' : widget.user.fullName),
      ),
      body: BlocConsumer<MovieListCubit, MovieListState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.movies.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _currentIndex == 0 ? _buildTrendingTab(state) : _buildSavedTab(),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _loadBookmarks();
          }
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Trending',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
