import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
import '../blocs/movie_detail/movie_detail_cubit.dart';
import '../blocs/movie_detail/movie_detail_state.dart';
import '../widgets/bookmark_button.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({
    required this.user,
    required this.movieId,
    this.initialMovie,
    super.key,
  });

  final AppUser user;
  final String movieId;
  final Movie? initialMovie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MovieDetailCubit, MovieDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.movie != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final movie = state.movie ?? initialMovie;

          if (state.isLoading && movie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && movie == null) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<MovieDetailCubit>().initialize(
                      user: user,
                      movieId: movieId,
                      initialMovie: initialMovie,
                    ),
                child: const Text('Retry loading movie'),
              ),
            );
          }

          if (movie == null) {
            return const SizedBox.shrink();
          }

          final posterUrl = movie.posterPath;

          return Stack(
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 420,
                    leading: IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    title: Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          posterUrl == null
                              ? Container(color: Colors.grey.shade300)
                              : CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.black.withOpacity(0.14),
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x1A006B5C),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Sci-Fi / Action',
                                    style: TextStyle(
                                      color: Color(0xFF006B5C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    height: 0.95,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.star, color: Colors.amber),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Trending',
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(width: 18),
                                    const Icon(Icons.calendar_today_outlined, size: 18),
                                    const SizedBox(width: 6),
                                    Text(movie.releaseDate ?? 'Unknown'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: BookmarkButton(
                          isBookmarked: state.isBookmarked,
                          onPressed: () => context.read<MovieDetailCubit>().toggleBookmark(movie),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      color: Color(0xFF003F74),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    movie.overview.isEmpty
                                        ? 'No description available for this movie.'
                                        : movie.overview,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF424751),
                                          height: 1.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Release',
                                          style: TextStyle(
                                            color: Color(0xFF006B5C),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movie.releaseDate ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Status',
                                          style: TextStyle(
                                            color: Color(0xFF006B5C),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Archived Classic',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => context.read<MovieDetailCubit>().toggleBookmark(movie),
                                icon: Icon(
                                  state.isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                                ),
                                label: Text(
                                  state.isBookmarked ? 'Bookmarked' : 'Bookmark Movie',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              onPressed: null,
                              icon: const Icon(Icons.play_arrow_rounded),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(56, 56),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
