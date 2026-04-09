import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  UserListCubit(this._userRepository) : super(const UserListState());

  final UserRepository _userRepository;

  Future<void> fetchInitial() async {
    emit(state.copyWith(isInitialLoading: true, clearError: true, page: 1));

    try {
      final page = await _userRepository.fetchUsers(page: 1);
      emit(
        state.copyWith(
          users: page.items,
          page: page.page,
          hasMore: page.hasMore,
          isInitialLoading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isInitialLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isInitialLoading) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final nextPageNumber = state.page + 1;
      final page = await _userRepository.fetchUsers(page: nextPageNumber);
      emit(
        state.copyWith(
          users: <AppUser>[...state.users, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
