import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/movie.dart';

class MovieTile extends StatelessWidget {
  const MovieTile({
    required this.movie,
    required this.onTap,
    required this.trailing,
    super.key,
  });

  final Movie movie;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath == null
        ? null
        : '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 84,
            child: posterUrl == null
                ? Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.movie),
                  )
                : CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(movie.title),
        subtitle: Text(movie.releaseDate ?? 'Unknown release date'),
        trailing: trailing,
      ),
    );
  }
}
