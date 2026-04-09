import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../core/network/retry_signal_service.dart';
import '../blocs/sync_status/sync_status_cubit.dart';
import '../blocs/sync_status/sync_status_state.dart';

class ReconnectingBanner extends StatelessWidget {
  const ReconnectingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: sl<RetrySignalService>().isRetrying,
      builder: (context, isRetrying, child) {
        return BlocBuilder<SyncStatusCubit, SyncStatusState>(
          builder: (context, state) {
            final isVisible = isRetrying || state.isSyncing || !state.isOnline;
            if (!isVisible) return const SizedBox.shrink();

            return Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    state.isOnline ? 'Reconnecting...' : 'Offline mode enabled',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
