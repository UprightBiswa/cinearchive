class AppEnv {
  const AppEnv._();

  static const String reqResApiKey = 'pub_7378396fa708c0eadbb0afa4eb3c1319';

  static const String omdbApiKey = '53b38503';

  static bool get hasReqResKey => reqResApiKey.trim().isNotEmpty;
  static bool get hasOmdbKey => omdbApiKey.trim().isNotEmpty;
}
