import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hearhere/features/cue/data/cue_repository.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';
import 'package:hearhere/features/auth/data/auth_repository.dart';

part 'map_controller.g.dart';

@riverpod
class MapController extends _$MapController {
  @override
  FutureOr<Set<Marker>> build() async {
    final cues = await ref.watch(cueRepositoryProvider).getCues();
    final user = ref.watch(currentUserModelProvider).value;
    final preferredLang = user?.preferredLanguage ?? 'en';
    
    // Filter cues by language
    // We only show cues that match the preference.
    // Ideally we would fall back to original if translation doesn't exist, 
    // but for now strict filtering is cleaner for the "Supported Languages" requirement.
    final filteredCues = cues.where((c) => c.language == preferredLang).toList();
    
    return _createMarkers(filteredCues);
  }

  Set<Marker> _createMarkers(List<CueModel> cues) {
    return cues.map((cue) {
      return Marker(
        markerId: MarkerId(cue.id),
        position: LatLng(cue.latitude, cue.longitude),
        infoWindow: InfoWindow(
          title: cue.title,
          snippet: cue.description,
        ),
        onTap: () {
          // Handle marker tap if needed (e.g., show mini-player or details)
          state = AsyncValue.data(state.value ?? {});
        },
      );
    }).toSet();
  }

  Future<void> refreshCues() async {
    state = await AsyncValue.guard(() async {
      final cues = await ref.read(cueRepositoryProvider).getCues();
      final user = ref.read(currentUserModelProvider).value;
      final preferredLang = user?.preferredLanguage ?? 'en';
      final filteredCues = cues.where((c) => c.language == preferredLang).toList();
      return _createMarkers(filteredCues);
    });
  }
}
