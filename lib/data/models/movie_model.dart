import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.posterPath,
    required super.overview,
    required super.releaseDate,
  });

  factory MovieModel.fromOmdbSearchJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['imdbID'] as String? ?? '',
      title: json['Title'] as String? ?? 'Untitled',
      posterPath: _normalizePoster(json['Poster'] as String?),
      overview: '',
      releaseDate: json['Year'] as String?,
    );
  }

  factory MovieModel.fromOmdbDetailJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['imdbID'] as String? ?? '',
      title: json['Title'] as String? ?? 'Untitled',
      posterPath: _normalizePoster(json['Poster'] as String?),
      overview: json['Plot'] as String? ?? '',
      releaseDate: json['Released'] as String? ?? json['Year'] as String?,
    );
  }

  static String? _normalizePoster(String? poster) {
    if (poster == null || poster.isEmpty || poster == 'N/A') {
      return null;
    }
    return poster;
  }
}
