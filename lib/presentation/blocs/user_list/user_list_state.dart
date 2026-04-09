import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_user.dart';

class UserListState extends Equatable {
  const UserListState({
    this.users = const <AppUser>[],
    this.page = 1,
    this.hasMore = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<AppUser> users;
  final int page;
  final bool hasMore;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  UserListState copyWith({
    List<AppUser>? users,
    int? page,
    bool? hasMore,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserListState(
      users: users ?? this.users,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        users,
        page,
        hasMore,
        isInitialLoading,
        isLoadingMore,
        errorMessage,
      ];
}
