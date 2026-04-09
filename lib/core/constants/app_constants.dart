class AppConstants {
  const AppConstants._();

  static const String appName = 'CineArchive';
  static const String reqResBaseUrl = 'https://reqres.in/api';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'http://image.tmdb.org/t/p/w185';

  static const String pendingUsersBox = 'pending_users_box';
  static const String bookmarksBox = 'bookmarks_box';

  static const String syncUsersTask = 'sync_pending_users_and_bookmarks';
  static const Duration syncFrequency = Duration(minutes: 15);
}
