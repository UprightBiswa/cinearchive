import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/movie_bookmark_model.dart';

class LocalBookmarkDataSource {
  Future<Box<String>> _box() async {
    return Hive.isBoxOpen(AppConstants.bookmarksBox)
        ? Hive.box<String>(AppConstants.bookmarksBox)
        : Hive.openBox<String>(AppConstants.bookmarksBox);
  }

  Future<List<MovieBookmarkModel>> getBookmarks() async {
    final box = await _box();
    return box.values.map(MovieBookmarkModel.fromRawJson).toList();
  }

  Future<void> upsertBookmark(MovieBookmarkModel bookmark) async {
    final box = await _box();
    await box.put(bookmark.id, bookmark.toRawJson());
  }

  Future<void> deleteBookmark(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}
