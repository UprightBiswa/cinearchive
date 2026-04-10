import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.user,
    required this.onTap,
    this.badgeLabel,
    super.key,
  });

  final AppUser user;
  final VoidCallback onTap;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final fallbackInitial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';
    final scheme = Theme.of(context).colorScheme;
    final jobLabel = badgeLabel ?? (user.job.trim().isEmpty ? 'Member' : user.job);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFF3F4F5),
                        backgroundImage: user.avatar != null
                            ? CachedNetworkImageProvider(user.avatar!)
                            : null,
                        child: user.avatar == null
                            ? Text(
                                fallbackInitial,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: user.isPendingSync
                                ? const Color(0xFF727782)
                                : const Color(0xFF006B5C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.firstName ?? user.fullName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.lastName ?? user.fullName.split(' ').skip(1).join(' '),
                          style: const TextStyle(
                            color: Color(0xFF727782),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.isPendingSync ? '$jobLabel • Pending Sync' : jobLabel,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.more_vert, color: scheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
