class AppConstants {
  const AppConstants._();

  static const String appName = 'CineArchive';
  static const String reqResBaseUrl = 'https://reqres.in/api';
  static const String omdbBaseUrl = 'https://www.omdbapi.com';
  static const String omdbSearchQuery = 'movie';

  static const String pendingUsersBox = 'pending_users_box';
  static const String bookmarksBox = 'bookmarks_box';

  static const String syncUsersTask = 'sync_pending_users_and_bookmarks';
  static const Duration syncFrequency = Duration(minutes: 15);
}
