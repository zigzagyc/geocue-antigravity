import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hearhere/features/admin/presentation/admin_controller.dart';
import 'package:hearhere/features/auth/domain/user_model.dart';

class AdminUserListScreen extends ConsumerWidget {
  const AdminUserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_problem),
            tooltip: 'Sync Missing Users',
            onPressed: () async {
              final restored = await ref.read(adminControllerProvider.notifier).syncOrphanedUsers();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restored $restored missing user profiles')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminControllerProvider),
          ),
        ],
      ),
      body: usersState.when(
        data: (users) {
          if (users.isEmpty) return const Center(child: Text('No users found.'));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                color: user.isDisabled ? Colors.grey.shade200 : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    radius: 20,
                    child: user.photoUrl == null ? Text(user.email.isNotEmpty ? user.email.substring(0, 1).toUpperCase() : '?') : null,
                  ),
                  title: Text(user.email + (user.isAdmin ? ' (Admin)' : '')),
                  subtitle: Text('ID: ${user.id}'),
                  children: [
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                           // Toggle Cues
                           SwitchListTile(
                             title: const Text('Can Create Cues'),
                             value: user.canCreateCues,
                             onChanged: (val) {
                               ref.read(adminControllerProvider.notifier).toggleCanCreateCues(user.id, user.canCreateCues);
                             },
                           ),
                           // Toggle Admin
                           SwitchListTile(
                             title: const Text('Is Admin'),
                             subtitle: const Text('Grant full system access'),
                             value: user.isAdmin,
                             onChanged: (val) {
                               // Confirmation Dialog?
                               ref.read(adminControllerProvider.notifier).toggleAdmin(user.id, user.isAdmin);
                             },
                           ),
                           // Disable User
                           SwitchListTile(
                             title: Text(user.isDisabled ? 'User Disabled' : 'User Active'),
                             subtitle: const Text('Prevent login and actions'),
                             value: !user.isDisabled,
                             activeColor: Colors.green,
                             inactiveTrackColor: Colors.red,
                             onChanged: (val) {
                               ref.read(adminControllerProvider.notifier).toggleUserDisabled(user.id, user.isDisabled);
                             },
                           ),
                           const Divider(),
                           OutlinedButton.icon(
                             onPressed: () async {
                               try {
                                 await ref.read(adminControllerProvider.notifier).resetPassword(user.email);
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset email sent')));
                                 }
                               } catch (e) {
                                 if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                 }
                               }
                             },
                             icon: const Icon(Icons.lock_reset),
                             label: const Text('Send Password Reset Email'),
                           )
                         ],
                       ),
                     ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/locked-areas');
        },
        child: const Icon(Icons.lock_outline),
        tooltip: 'Manage Locked Areas',
      ),
    );
  }
}
