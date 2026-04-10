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
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CineArchive'),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          color: const Color(0xFF02569B),
        ),
        actions: <Widget>[
          if (isWide) ...<Widget>[
            TextButton(
              onPressed: () {},
              child: const Text(
                'Users',
                style: TextStyle(
                  color: Color(0xFF02569B),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            TextButton(
              onPressed: null,
              child: const Text(
                'Movies',
                style: TextStyle(
                  color: Color(0xFF727782),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 42,
                            color: Color(0xFF02569B),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unable to load users',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF003F74),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF727782),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => context.read<UserListCubit>().fetchInitial(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry loading users'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Directory',
                                    style: TextStyle(
                                      color: Color(0xFF006B5C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.4,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'CineArchive Users',
                                    style: TextStyle(
                                      color: Color(0xFF003F74),
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      height: 0.95,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isWide)
                              Container(
                                width: 96,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF02569B),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                          ],
                        ),
                        if (!isWide) ...<Widget>[
                          const SizedBox(height: 14),
                          Container(
                            width: 92,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF02569B),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
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
                SliverToBoxAdapter(
                  child: SizedBox(height: isWide ? 100 : 132),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: isWide
          ? null
          : SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x1402569B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.group_rounded, color: Color(0xFF02569B)),
                            SizedBox(height: 4),
                            Text(
                              'Users',
                              style: TextStyle(
                                color: Color(0xFF02569B),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Select a user first to open movies.'),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.movie_outlined, color: Color(0xFF727782)),
                              SizedBox(height: 4),
                              Text(
                                'Movies',
                                style: TextStyle(
                                  color: Color(0xFF727782),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
