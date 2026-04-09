import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String? releaseDate;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        posterPath,
        overview,
        releaseDate,
      ];
}
