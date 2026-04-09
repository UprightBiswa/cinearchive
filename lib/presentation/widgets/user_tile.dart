import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.user,
    required this.onTap,
    super.key,
  });

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fallbackInitial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: user.avatar != null
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: user.avatar == null ? Text(fallbackInitial) : null,
        ),
        title: Text(user.fullName),
        subtitle: Text(
          user.isPendingSync ? '${user.job} • pending sync' : user.job,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
