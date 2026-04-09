import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
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
      for (final item in bookmarks) {
        _bookmarkState[item.movieId] = true;
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      context.read<MovieListCubit>().fetchMore();
    }
  }

  Future<void> _toggleBookmark(Movie movie) async {
    await _movieRepository.toggleBookmark(user: widget.user, movie: movie);
    if (!mounted) return;
    setState(() {
      _bookmarkState[movie.id] = !(_bookmarkState[movie.id] ?? false);
    });
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
      appBar: AppBar(title: Text('${widget.user.fullName} Movies')),
      body: BlocConsumer<MovieListCubit, MovieListState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.movies.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
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

          return ListView.builder(
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
                onTap: () => context.push(
                  '/movie-detail',
                  extra: <String, dynamic>{
                    'movieId': movie.id,
                    'movie': movie,
                    'user': widget.user,
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
