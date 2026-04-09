import 'package:equatable/equatable.dart';

class SyncStatusState extends Equatable {
  const SyncStatusState({
    this.isOnline = true,
    this.isSyncing = false,
  });

  final bool isOnline;
  final bool isSyncing;

  SyncStatusState copyWith({
    bool? isOnline,
    bool? isSyncing,
  }) {
    return SyncStatusState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => <Object?>[isOnline, isSyncing];
}
