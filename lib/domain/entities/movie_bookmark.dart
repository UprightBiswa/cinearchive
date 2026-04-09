import 'package:equatable/equatable.dart';

class MovieBookmark extends Equatable {
  const MovieBookmark({
    required this.id,
    required this.userLocalId,
    required this.movieId,
    required this.title,
    this.posterPath,
    this.releaseDate,
    this.userRemoteId,
    this.isPendingSync = false,
  });

  final String id;
  final String userLocalId;
  final String? userRemoteId;
  final int movieId;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final bool isPendingSync;

  @override
  List<Object?> get props => <Object?>[
        id,
        userLocalId,
        userRemoteId,
        movieId,
        title,
        posterPath,
        releaseDate,
        isPendingSync,
      ];
}
