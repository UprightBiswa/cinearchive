import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/local/local_bookmark_data_source.dart';
import '../../data/datasources/local/local_user_data_source.dart';
import '../../data/datasources/remote/movie_remote_data_source.dart';
import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/blocs/add_user/add_user_cubit.dart';
import '../../presentation/blocs/movie_detail/movie_detail_cubit.dart';
import '../../presentation/blocs/movie_list/movie_list_cubit.dart';
import '../../presentation/blocs/sync_status/sync_status_cubit.dart';
import '../../presentation/blocs/user_list/user_list_cubit.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../network/retry_signal_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  if (sl.isRegistered<RetrySignalService>()) return;

  sl
    ..registerLazySingleton<RetrySignalService>(RetrySignalService.new)
    ..registerLazySingleton<ApiClientFactory>(
      () => ApiClientFactory(sl<RetrySignalService>()),
    )
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(sl<Connectivity>()),
    )
    ..registerLazySingleton<LocalUserDataSource>(LocalUserDataSource.new)
    ..registerLazySingleton<LocalBookmarkDataSource>(
      LocalBookmarkDataSource.new,
    )
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(sl<ApiClientFactory>().createReqResClient()),
    )
    ..registerLazySingleton<MovieRemoteDataSource>(
      () => MovieRemoteDataSource(sl<ApiClientFactory>().createOmdbClient()),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        remoteDataSource: sl<UserRemoteDataSource>(),
        localUserDataSource: sl<LocalUserDataSource>(),
        localBookmarkDataSource: sl<LocalBookmarkDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    )
    ..registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(
        remoteDataSource: sl<MovieRemoteDataSource>(),
        localBookmarkDataSource: sl<LocalBookmarkDataSource>(),
        connectivityService: sl<ConnectivityService>(),
      ),
    )
    ..registerFactory<UserListCubit>(() => UserListCubit(sl<UserRepository>()))
    ..registerFactory<AddUserCubit>(() => AddUserCubit(sl<UserRepository>()))
    ..registerFactory<MovieListCubit>(() => MovieListCubit(sl<MovieRepository>()))
    ..registerFactory(
      () => MovieDetailCubit(sl<MovieRepository>()),
    )
    ..registerLazySingleton<SyncStatusCubit>(
      () => SyncStatusCubit(sl<ConnectivityService>(), sl<UserRepository>()),
    );
}
