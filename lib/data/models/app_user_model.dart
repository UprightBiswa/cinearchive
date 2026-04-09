import 'dart:convert';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.localId,
    required super.name,
    required super.job,
    super.remoteId,
    super.firstName,
    super.lastName,
    super.avatar,
    super.createdAt,
    super.isPendingSync,
  });

  factory AppUserModel.fromReqResJson(Map<String, dynamic> json) {
    return AppUserModel(
      localId: 'remote_${json['id']}',
      remoteId: json['id']?.toString(),
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      job: 'Member',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatar: json['avatar'] as String?,
      isPendingSync: false,
    );
  }

  factory AppUserModel.fromCreateResponse(
    Map<String, dynamic> json, {
    required String localId,
    required String name,
    required String job,
    required bool isPendingSync,
  }) {
    return AppUserModel(
      localId: localId,
      remoteId: json['id']?.toString(),
      name: name,
      job: job,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      isPendingSync: isPendingSync,
    );
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      localId: json['localId'] as String,
      remoteId: json['remoteId'] as String?,
      name: json['name'] as String? ?? '',
      job: json['job'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'localId': localId,
      'remoteId': remoteId,
      'name': name,
      'job': job,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'isPendingSync': isPendingSync,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  factory AppUserModel.fromRawJson(String value) {
    return AppUserModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
