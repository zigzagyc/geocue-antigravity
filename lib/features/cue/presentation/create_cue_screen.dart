import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'create_cue_controller.dart';
import 'widgets/cue_form.dart';

class CreateCueScreen extends ConsumerWidget {
  const CreateCueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(createCueControllerProvider, (previous, state) {
       if (state.hasError) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
       }
       if (!state.isLoading && !state.hasError && previous?.isLoading == true) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cue Created!')));
         context.pop();
       }
    });

    final state = ref.watch(createCueControllerProvider);
    final isLoading = state.isLoading;
    
    // Get query params if available
    final GoRouterState routerState = GoRouterState.of(context);
    final String? latParam = routerState.uri.queryParameters['lat'];
    final String? lngParam = routerState.uri.queryParameters['lng'];
    
    double? initialLat;
    double? initialLng;
    
    if (latParam != null && lngParam != null) {
      initialLat = double.tryParse(latParam);
      initialLng = double.tryParse(lngParam);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Cue')),
      body: CueForm(
        isLoading: isLoading,
        initialLat: initialLat,
        initialLng: initialLng,
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
             ref.read(createCueControllerProvider.notifier).createCueFromAudio(
              title: title,
              description: description,
              audioFilePath: audioPath!, // Form ensures this is not null if valid
              language: null, // Auto-detect
              lat: lat,
              lng: lng,
              radius: radius,
              zoneType: zoneType,
              polygonPoints: polygonPoints,
            );
          } else {
             ref.read(createCueControllerProvider.notifier).createCueFromText(
              title: title, // Use title as title (was title controller)
              description: description, // Not used in method? Method has title, description, textContent.
              // Wait, original logic:
              // createCueFromText(title: title, description: description, textContent: description)
              // This seems redundant. Let's keep it consistent with previous logic.
              // Previous: description was used for both description and textContent?
              // "description" controller was labeled "Text Content".
              // So for Text Mode: description IS the content.
              // For Audio Mode: description is optional description.
              textContent: textContent!, // Form ensures not null in text mode
              language: null, // Auto-detect
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
