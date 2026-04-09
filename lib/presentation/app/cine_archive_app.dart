import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/sync_status/sync_status_cubit.dart';
import '../widgets/reconnecting_banner.dart';

class CineArchiveApp extends StatefulWidget {
  const CineArchiveApp({super.key});

  @override
  State<CineArchiveApp> createState() => _CineArchiveAppState();
}

class _CineArchiveAppState extends State<CineArchiveApp> {
  @override
  void initState() {
    super.initState();
    sl<SyncStatusCubit>().start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncStatusCubit>.value(
      value: sl<SyncStatusCubit>(),
      child: MaterialApp.router(
        title: 'CineArchive',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              child ?? const SizedBox.shrink(),
              const ReconnectingBanner(),
            ],
          );
        },
      ),
    );
  }
}
