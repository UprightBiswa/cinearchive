import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_user.dart';

class AddUserState extends Equatable {
  const AddUserState({
    this.isSubmitting = false,
    this.createdUser,
    this.errorMessage,
  });

  final bool isSubmitting;
  final AppUser? createdUser;
  final String? errorMessage;

  AddUserState copyWith({
    bool? isSubmitting,
    AppUser? createdUser,
    String? errorMessage,
    bool clearCreatedUser = false,
    bool clearError = false,
  }) {
    return AddUserState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdUser: clearCreatedUser ? null : createdUser ?? this.createdUser,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[isSubmitting, createdUser, errorMessage];
}
