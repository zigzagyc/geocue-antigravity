import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'create_cue_controller.dart';
import 'widgets/cue_form.dart';
import '../domain/cue_model.dart';
import 'cue_list_screen.dart'; // import to access provider if needed, or just import domain

class EditCueScreen extends ConsumerWidget {
  final CueModel cue;

  const EditCueScreen({super.key, required this.cue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(createCueControllerProvider, (previous, state) {
       if (state.hasError) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
       }
       if (!state.isLoading && !state.hasError && previous?.isLoading == true) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cue Updated!')));
         context.pop();
       }
    });

    final state = ref.watch(createCueControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Cue')),
      body: CueForm(
        isLoading: isLoading,
        initialCue: cue,
        onSave: ({
          required title,
          required description,
          required isAudioMode,
          audioPath,
          textContent,
          required lat,
          required lng,
          required radius,
          required zoneType,
          polygonPoints
        }) {
          if (isAudioMode) {
             ref.read(createCueControllerProvider.notifier).updateCueFromAudio(
              cueId: cue.id,
              originalAudioUrl: cue.audioUrl,
              createdAt: cue.createdAt,
              title: title,
              description: description,
              newAudioFilePath: audioPath, // Can be null if not re-recorded
              language: 'en',
              lat: lat,
              lng: lng,
              radius: radius,
              zoneType: zoneType,
              polygonPoints: polygonPoints,
            );
          } else {
             ref.read(createCueControllerProvider.notifier).updateCueFromText(
              cueId: cue.id,
              createdAt: cue.createdAt,

              title: title,
              description: description,
              textContent: textContent!,
              language: 'en',
              lat: lat,
              lng: lng,
              radius: radius,
              zoneType: zoneType,
              polygonPoints: polygonPoints,
            );
          }
        },
      ),
    );
  }
}
