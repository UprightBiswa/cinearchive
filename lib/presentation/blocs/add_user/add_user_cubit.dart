import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/user_repository.dart';
import 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit(this._userRepository) : super(const AddUserState());

  final UserRepository _userRepository;

  Future<void> submit({
    required String name,
    required String job,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearCreatedUser: true,
      ),
    );

    try {
      final user = await _userRepository.createUser(name: name, job: job);
      emit(
        state.copyWith(
          isSubmitting: false,
          createdUser: user,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
