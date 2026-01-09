import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/cue_repository.dart';
import '../../cue/domain/cue_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../playback/service/playback_service.dart';

part 'cue_list_screen.g.dart';

class CueListScreen extends ConsumerWidget {
  const CueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch logic for cues would come here once provider is ready to expose stream
    // For now we can use FutureBuilder or just watch the repository if we expose a stream provider
    
    // Stub
    final cuesAsync = ref.watch(cuesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cues')),
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
                        // Playback service now handles both Audio URL (Voice) and empty URL (TTS)
                        ref.read(playbackServiceProvider.notifier).playCue(cue);
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
