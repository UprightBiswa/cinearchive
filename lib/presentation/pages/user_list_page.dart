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
  static const List<String> _roleLabels = <String>[
    'Premium Member',
    'Administrator',
    'Curator',
    'Viewer',
    'Executive',
  ];

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
      appBar: AppBar(
        title: const Text('CineArchive'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF02569B),
              child: Text(
                'CA',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
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
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xCC006B5C),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.sync, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'RECONNECTING...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Directory',
                          style: TextStyle(
                            color: Color(0xFF006B5C),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'CineArchive Users',
                          style: TextStyle(
                            color: Color(0xFF003F74),
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 92,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF02569B),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 1.16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = state.users[index];
                        return UserTile(
                          user: user,
                          badgeLabel: _roleLabels[index % _roleLabels.length],
                          onTap: () => context.push('/movies', extra: user),
                        );
                      },
                      childCount: state.users.length,
                    ),
                  ),
                ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}
