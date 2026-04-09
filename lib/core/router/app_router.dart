import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/blocs/add_user/add_user_cubit.dart';
import '../../presentation/blocs/movie_detail/movie_detail_cubit.dart';
import '../../presentation/blocs/movie_list/movie_list_cubit.dart';
import '../../presentation/blocs/user_list/user_list_cubit.dart';
import '../../presentation/pages/add_user_page.dart';
import '../../presentation/pages/movie_detail_page.dart';
import '../../presentation/pages/movie_list_page.dart';
import '../../presentation/pages/user_list_page.dart';
import '../di/injection_container.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<UserListCubit>(
          create: (_) => sl<UserListCubit>()..fetchInitial(),
          child: const UserListPage(),
        ),
      ),
      GoRoute(
        path: '/add-user',
        builder: (context, state) => BlocProvider<AddUserCubit>(
          create: (_) => sl<AddUserCubit>(),
          child: const AddUserPage(),
        ),
      ),
      GoRoute(
        path: '/movies',
        builder: (context, state) => BlocProvider<MovieListCubit>(
          create: (_) => sl<MovieListCubit>()..fetchInitial(),
          child: MovieListPage(user: state.extra! as AppUser),
        ),
      ),
      GoRoute(
        path: '/movie-detail',
        builder: (context, state) {
          final payload = state.extra! as Map<String, dynamic>;
          final movieId = payload['movieId'] as int;
          return BlocProvider<MovieDetailCubit>(
            create: (_) => sl<MovieDetailCubit>()..load(movieId),
            child: MovieDetailPage(
              user: payload['user'] as AppUser,
              movieId: movieId,
              initialMovie: payload['movie'] as Movie?,
            ),
          );
        },
      ),
    ],
  );
}
