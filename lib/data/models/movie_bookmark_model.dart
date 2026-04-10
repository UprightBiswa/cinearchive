import 'dart:convert';

import '../../domain/entities/movie_bookmark.dart';

class MovieBookmarkModel extends MovieBookmark {
  const MovieBookmarkModel({
    required super.id,
    required super.userLocalId,
    required super.movieId,
    required super.title,
    super.posterPath,
    super.releaseDate,
    super.userRemoteId,
    super.isPendingSync,
  });

  factory MovieBookmarkModel.fromJson(Map<String, dynamic> json) {
    return MovieBookmarkModel(
      id: json['id'] as String,
      userLocalId: json['userLocalId'] as String,
      userRemoteId: json['userRemoteId'] as String?,
      movieId: json['movieId'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      releaseDate: json['releaseDate'] as String?,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userLocalId': userLocalId,
      'userRemoteId': userRemoteId,
      'movieId': movieId,
      'title': title,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'isPendingSync': isPendingSync,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory MovieBookmarkModel.fromRawJson(String value) {
    return MovieBookmarkModel.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
