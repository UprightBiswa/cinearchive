import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../domain/repositories/user_repository.dart';
import 'sync_status_state.dart';

class SyncStatusCubit extends Cubit<SyncStatusState> {
  SyncStatusCubit(
    this._connectivityService,
    this._userRepository,
  ) : super(const SyncStatusState());

  final ConnectivityService _connectivityService;
  final UserRepository _userRepository;
  StreamSubscription<bool>? _subscription;

  Future<void> start() async {
    emit(state.copyWith(isOnline: await _connectivityService.isOnline));

    _subscription ??= _connectivityService.watchIsOnline().listen((online) async {
      emit(state.copyWith(isOnline: online, isSyncing: online));
      if (online) {
        await _userRepository.syncPendingUsersAndBookmarks();
      }
      emit(state.copyWith(isOnline: online, isSyncing: false));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
