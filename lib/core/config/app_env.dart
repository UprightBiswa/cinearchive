class AppEnv {
  const AppEnv._();

  static const String reqResApiKey = String.fromEnvironment(
    'REQRES_API_KEY',
    defaultValue: '',
  );

  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  static bool get hasReqResKey => reqResApiKey.trim().isNotEmpty;
  static bool get hasTmdbKey => tmdbApiKey.trim().isNotEmpty;
}
