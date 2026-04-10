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
    final threshold = _scrollController.position.maxScrollExtent * 0.82;
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

  Widget _buildHeader(bool isWide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Trending Movies',
            style: TextStyle(
              color: Color(0xFF003F74),
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 80,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF006B5C),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
            child: const Text(
              'Discover the most viewed and highly-rated cinematic masterpieces curated by our global community of film architects.',
              style: TextStyle(
                color: Color(0xFF424751),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTab(MovieListState state) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100 ? 4 : width >= 700 ? 2 : 1;

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

    final featuredMovie = state.movies.isNotEmpty ? state.movies.first : null;
    final gridMovies = state.movies.length > 1 ? state.movies.sublist(1) : <Movie>[];

    return RefreshIndicator(
      onRefresh: () => context.read<MovieListCubit>().fetchInitial(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildHeader(width >= 900)),
          if (featuredMovie != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  height: width >= 900 ? 520 : 420,
                  child: MovieTile(
                    movie: featuredMovie,
                    featured: true,
                    trailing: BookmarkButton(
                      isBookmarked: _bookmarkState[featuredMovie.id] ?? false,
                      onPressed: () => _toggleBookmark(featuredMovie),
                    ),
                    onTap: () => _openMovieDetail(featuredMovie),
                  ),
                ),
              ),
            ),
          if (gridMovies.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final movie = gridMovies[index];
                    return MovieTile(
                      movie: movie,
                      trailing: BookmarkButton(
                        isBookmarked: _bookmarkState[movie.id] ?? false,
                        onPressed: () => _toggleBookmark(movie),
                      ),
                      onTap: () => _openMovieDetail(movie),
                    );
                  },
                  childCount: gridMovies.length,
                ),
              ),
            ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
              child: Column(
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: const <Widget>[
                      _PageChip(label: '<', active: false),
                      _PageChip(label: '1', active: true),
                      _PageChip(label: '2', active: false),
                      _PageChip(label: '3', active: false),
                      _PageChip(label: '...', active: false),
                      _PageChip(label: '12', active: false),
                      _PageChip(label: '>', active: false),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Viewing page ${state.page}${state.hasMore ? ' and more available' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF727782),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.62,
      ),
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
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.menu_rounded),
          color: const Color(0xFF02569B),
        ),
        title: const Text('CineArchive'),
        actions: <Widget>[
          if (isWide) ...<Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Users',
                style: TextStyle(
                  color: Color(0xFF727782),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Movies',
                style: TextStyle(
                  color: Color(0xFF02569B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF02569B),
              child: Text(
                widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.group_outlined, color: Color(0xFF727782)),
                        SizedBox(height: 4),
                        Text(
                          'Users',
                          style: TextStyle(
                            color: Color(0xFF727782),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x1402569B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.movie_rounded, color: Color(0xFF02569B)),
                      SizedBox(height: 4),
                      Text(
                        'Movies',
                        style: TextStyle(
                          color: Color(0xFF02569B),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF02569B) : const Color(0xFFEDEEEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF424751),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
