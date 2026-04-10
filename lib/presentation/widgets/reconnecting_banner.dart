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
            final message =
                state.isOnline ? 'Reconnecting...' : 'Offline mode enabled';

            return IgnorePointer(
              ignoring: true,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                offset: isVisible ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: isVisible ? 1 : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: state.isOnline
                                ? const Color(0xE6006B5C)
                                : const Color(0xE62E3132),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                state.isOnline ? Icons.sync : Icons.cloud_off,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
