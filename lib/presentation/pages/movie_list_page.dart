import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = context.read<MovieListCubit>();
    if (!_scrollController.hasClients || cubit.state.selectedTabIndex != 0) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.82;
    if (_scrollController.position.pixels >= threshold) {
      cubit.fetchMore();
    }
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
    if (!mounted) return;
    await context.read<MovieListCubit>().loadBookmarks();
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.movie_filter_outlined,
                      size: 42,
                      color: Color(0xFF02569B),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load movies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF003F74),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF727782),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.read<MovieListCubit>().fetchInitial(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry loading movies'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                      isBookmarked: state.bookmarkMap[featuredMovie.id] ?? false,
                      onPressed: () => context.read<MovieListCubit>().toggleBookmark(featuredMovie),
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
                        isBookmarked: state.bookmarkMap[movie.id] ?? false,
                        onPressed: () => context.read<MovieListCubit>().toggleBookmark(movie),
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

  Widget _buildSavedTab(MovieListState state) {
    if (state.isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.savedBookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.bookmark_outline_rounded,
                      size: 42,
                      color: Color(0xFF02569B),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved movies yet for ${widget.user.fullName}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF003F74),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bookmark titles from the Trending tab and they will appear here, even when the app is offline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF727782),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      itemCount: state.savedBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = state.savedBookmarks[index];
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
            onPressed: () => context.read<MovieListCubit>().toggleBookmark(movie),
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
              onPressed: null,
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
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: state.selectedTabIndex == 0 ? _buildTrendingTab(state) : _buildSavedTab(state),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BlocBuilder<MovieListCubit, MovieListState>(
          builder: (context, state) {
            return Container(
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.read<MovieListCubit>().selectTab(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: state.selectedTabIndex == 0
                              ? const Color(0x1402569B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.movie_rounded,
                              color: state.selectedTabIndex == 0
                                  ? const Color(0xFF02569B)
                                  : const Color(0xFF727782),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Movies',
                              style: TextStyle(
                                color: state.selectedTabIndex == 0
                                    ? const Color(0xFF02569B)
                                    : const Color(0xFF727782),
                                fontSize: 10,
                                fontWeight: state.selectedTabIndex == 0
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.read<MovieListCubit>().selectTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: state.selectedTabIndex == 1
                              ? const Color(0x1402569B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.bookmark_rounded,
                              color: state.selectedTabIndex == 1
                                  ? const Color(0xFF02569B)
                                  : const Color(0xFF727782),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saved',
                              style: TextStyle(
                                color: state.selectedTabIndex == 1
                                    ? const Color(0xFF02569B)
                                    : const Color(0xFF727782),
                                fontSize: 10,
                                fontWeight: state.selectedTabIndex == 1
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
