import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/movie.dart';

class MovieTile extends StatelessWidget {
  const MovieTile({
    required this.movie,
    required this.onTap,
    required this.trailing,
    this.featured = false,
    super.key,
  });

  final Movie movie;
  final VoidCallback onTap;
  final Widget trailing;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath == null
        ? null
        : '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: featured ? _FeaturedMovieCard(movie: movie, posterUrl: posterUrl, trailing: trailing) : _StandardMovieCard(movie: movie, posterUrl: posterUrl, trailing: trailing),
      ),
    );
  }
}

class _FeaturedMovieCard extends StatelessWidget {
  const _FeaturedMovieCard({
    required this.movie,
    required this.posterUrl,
    required this.trailing,
  });

  final Movie movie;
  final String? posterUrl;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        posterUrl == null
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF003F74), Color(0xFF02569B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.movie_creation_outlined, color: Colors.white70, size: 72),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: posterUrl!,
                  fit: BoxFit.cover,
                ),
              ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0x11000000), Color(0xD9000000)],
              stops: <double>[0.45, 1],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: trailing,
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF006B5C),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                movie.releaseDate ?? 'Unknown release date',
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandardMovieCard extends StatelessWidget {
  const _StandardMovieCard({
    required this.movie,
    required this.posterUrl,
    required this.trailing,
  });

  final Movie movie;
  final String? posterUrl;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: posterUrl == null
                      ? Container(
                          color: const Color(0xFFE7E8E9),
                          child: const Icon(Icons.movie, size: 44),
                        )
                      : CachedNetworkImage(
                          imageUrl: posterUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: trailing,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                movie.releaseDate ?? 'Unknown release date',
                style: const TextStyle(
                  color: Color(0xFF727782),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
