import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hearhere/features/admin/presentation/admin_controller.dart';
import 'package:hearhere/features/admin/domain/locked_area_model.dart';
import 'package:intl/intl.dart';

class LockedAreaListScreen extends ConsumerWidget {
  const LockedAreaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockedAreasAsync = ref.watch(lockedAreasStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Areas'),
      ),
      body: lockedAreasAsync.when(
        data: (areas) {
          if (areas.isEmpty) {
            return const Center(child: Text('No locked areas found.'));
          }
          return ListView.builder(
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              return ListTile(
                leading: const Icon(Icons.lock, color: Colors.orange),
                title: Text(area.reason ?? 'Restricted Zone'),
                subtitle: Text(
                  'Lat: ${area.latitude.toStringAsFixed(4)}, Lng: ${area.longitude.toStringAsFixed(4)}\n'
                  'Radius: ${area.radius.toStringAsFixed(0)}m\n'
                  'Created: ${DateFormat.yMMMd().format(area.createdAt)}'
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Confirm delete
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unlock Area?'),
                        content: const Text('This will allow users to create cues in this location again.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(adminControllerProvider.notifier).deleteLockedArea(area.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Unlock', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/create-locked-area'),
        child: const Icon(Icons.add_location_alt),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
