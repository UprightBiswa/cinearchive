import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.localId,
    required this.name,
    required this.job,
    this.remoteId,
    this.firstName,
    this.lastName,
    this.avatar,
    this.createdAt,
    this.isPendingSync = false,
  });

  final String localId;
  final String? remoteId;
  final String name;
  final String job;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final DateTime? createdAt;
  final bool isPendingSync;

  String get fullName {
    if (name.trim().isNotEmpty) return name.trim();

    return <String?>[firstName, lastName]
        .where((part) => part != null && part!.trim().isNotEmpty)
        .cast<String>()
        .join(' ');
  }

  AppUser copyWith({
    String? localId,
    String? remoteId,
    String? name,
    String? job,
    String? firstName,
    String? lastName,
    String? avatar,
    DateTime? createdAt,
    bool? isPendingSync,
  }) {
    return AppUser(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      job: job ?? this.job,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        localId,
        remoteId,
        name,
        job,
        firstName,
        lastName,
        avatar,
        createdAt,
        isPendingSync,
      ];
}
