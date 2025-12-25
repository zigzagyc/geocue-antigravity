import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/cue_repository.dart';

class CueListScreen extends ConsumerWidget {
  const CueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch logic for cues would come here once provider is ready to expose stream
    // For now we can use FutureBuilder or just watch the repository if we expose a stream provider
    
    // Stub
    return Scaffold(
      appBar: AppBar(title: const Text('My Cues')),
      body: const Center(child: Text('List of cues will be here')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           context.push('/create-cue');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
