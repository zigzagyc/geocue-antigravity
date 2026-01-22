import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/cue_repository.dart';
import '../../cue/domain/cue_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../playback/service/playback_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../admin/presentation/admin_controller.dart';

part 'cue_list_screen.g.dart';

class CueListScreen extends ConsumerWidget {
  const CueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch logic for cues would come here once provider is ready to expose stream
    // For now we can use FutureBuilder or just watch the repository if we expose a stream provider
    
    // Stub
    final cuesAsync = ref.watch(cuesStreamProvider);
    final currentUser = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cues'),
        actions: [
          if (currentUser.value?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Dashboard',
              onPressed: () => context.push('/admin'),
            ),
        ],
      ),
      body: cuesAsync.when(
        data: (cues) {
          if (cues.isEmpty) {
            return const Center(child: Text('No cues yet. Create one!'));
          }
          return ListView.builder(
            itemCount: cues.length,
            itemBuilder: (context, index) {
              final cue = cues[index];
              return ListTile(
                title: Text(cue.title),
                subtitle: Text(cue.description ?? ''),
                leading: Icon(cue.audioUrl != null ? Icons.mic : Icons.text_fields),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.green),
                      onPressed: () {
                        final audioUrl = cue.audioUrl;
                        ref.read(playbackServiceProvider.notifier).playCue(cue);
                      },
                    ),
                    if (currentUser.value != null && (currentUser.value!.id == cue.ownerId || currentUser.value!.isAdmin)) ...[
                      if (currentUser.value!.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.lock_outline, color: Colors.orange),
                          tooltip: 'Lock this location',
                          onPressed: () {
                             showDialog(
                               context: context,
                               builder: (ctx) => AlertDialog(
                                 title: const Text('Lock Cue Location?'),
                                 content: Text('This will create a restricted zone at this cue\'s location (Radius: ${cue.radius.round()}m).\n\nNew cues cannot be created here, but this existing cue will remain editable.'),
                                 actions: [
                                   TextButton(
                                     onPressed: () => Navigator.pop(ctx),
                                     child: const Text('Cancel'),
                                   ),
                                   TextButton(
                                     onPressed: () {
                                       ref.read(adminControllerProvider.notifier).createLockedArea(
                                         latitude: cue.latitude,
                                         longitude: cue.longitude,
                                         radius: cue.radius,
                                         reason: 'Protected: ${cue.title}',
                                       );
                                       Navigator.pop(ctx);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('Location Locked Successfully')),
                                       );
                                     },
                                     child: const Text('Lock', style: TextStyle(color: Colors.orange)),
                                   ),
                                 ],
                               ),
                             );
                          },
                        ),
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            context.push('/edit-cue', extra: cue);
                          },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                           ref.read(cueRepositoryProvider).deleteCue(cue.id);
                        },
                      ),
                    ],
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
           context.push('/create-cue');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

@riverpod
Stream<List<CueModel>> cuesStream(Ref ref) {
  final repository = ref.watch(cueRepositoryProvider);
  return repository.watchCues();
}
