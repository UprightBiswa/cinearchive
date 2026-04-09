import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.posterPath,
    required super.overview,
    required super.releaseDate,
  });

  factory MovieModel.fromTmdbJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String? ?? '',
      releaseDate: json['release_date'] as String?,
    );
  }
}
