import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/add_user/add_user_cubit.dart';
import '../blocs/add_user/add_user_state.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CineArchive')),
      body: BlocConsumer<AddUserCubit, AddUserState>(
        listener: (context, state) {
          if (state.createdUser != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.createdUser!.isPendingSync
                      ? 'Saved offline. It will sync automatically.'
                      : 'User created successfully.',
                ),
              ),
            );
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Administration',
                    style: TextStyle(
                      color: Color(0xFF006B5C),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add New User',
                    style: TextStyle(
                      color: Color(0xFF003F74),
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B5C),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: <Widget>[
                                Icon(Icons.cloud_sync, color: Color(0xFF006B5C)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Cloud Sync Active • Offline mode supported',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'e.g. Elena Rodriguez',
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jobController,
                            decoration: const InputDecoration(
                              labelText: 'Job Title',
                              hintText: 'e.g. Lead Archivist',
                              suffixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Job is required'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        context.read<AddUserCubit>().submit(
                                              name: _nameController.text.trim(),
                                              job: _jobController.text.trim(),
                                            );
                                      }
                                    },
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_alt_1),
                              label: Text(state.isSubmitting ? 'Creating...' : 'Create User'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x1402569B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.info_outline, color: Color(0xFF02569B)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Architect Guidance',
                              style: TextStyle(
                                color: Color(0xFF003F74),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Offline-created users can immediately open movies and bookmark titles. Sync will link them properly when connectivity returns.',
                              style: TextStyle(
                                color: Color(0xFF727782),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
