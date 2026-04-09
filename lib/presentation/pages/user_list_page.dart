import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/user_list/user_list_cubit.dart';
import '../blocs/user_list/user_list_state.dart';
import '../widgets/user_tile.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      context.read<UserListCubit>().fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/add-user');
          if (!context.mounted) return;
          context.read<UserListCubit>().fetchInitial();
        },
        label: const Text('Add user'),
        icon: const Icon(Icons.person_add_alt_1),
      ),
      body: BlocConsumer<UserListCubit, UserListState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.users.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.users.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<UserListCubit>().fetchInitial(),
                child: const Text('Retry loading users'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<UserListCubit>().fetchInitial(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.users.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = state.users[index];
                return UserTile(
                  user: user,
                  onTap: () => context.push('/movies', extra: user),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
