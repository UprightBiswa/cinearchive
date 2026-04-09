import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../blocs/movie_detail/movie_detail_cubit.dart';
import '../blocs/movie_detail/movie_detail_state.dart';
import '../widgets/bookmark_button.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({
    required this.user,
    this.initialMovie,
    super.key,
  });

  final AppUser user;
  final Movie? initialMovie;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieRepository _movieRepository = sl<MovieRepository>();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMovie != null) {
      _loadBookmarkStatus(widget.initialMovie!.id);
    }
  }

  Future<void> _loadBookmarkStatus(int movieId) async {
    final isBookmarked = await _movieRepository.isBookmarked(
      userLocalId: widget.user.localId,
      movieId: movieId,
    );
    if (!mounted) return;
    setState(() => _isBookmarked = isBookmarked);
  }

  Future<void> _toggleBookmark(Movie movie) async {
    await _movieRepository.toggleBookmark(user: widget.user, movie: movie);
    if (!mounted) return;
    setState(() => _isBookmarked = !_isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        builder: (context, state) {
          final movie = state.movie ?? widget.initialMovie;

          if (state.isLoading && movie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && movie == null) {
            return Center(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Unable to load movie'),
              ),
            );
          }

          if (movie == null) {
            return const SizedBox.shrink();
          }

          final posterUrl = movie.posterPath == null
              ? null
              : '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}';

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                flexibleSpace: FlexibleSpaceBar(
                  background: posterUrl == null
                      ? Container(color: Colors.grey.shade300)
                      : CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BookmarkButton(
                      isBookmarked: _isBookmarked,
                      onPressed: () => _toggleBookmark(movie),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(movie.title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(movie.releaseDate ?? 'Unknown release date'),
                      const SizedBox(height: 24),
                      Text(
                        movie.overview.isEmpty
                            ? 'No description available for this movie.'
                            : movie.overview,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
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
