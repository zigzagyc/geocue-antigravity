import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hearhere/features/cue/data/cue_repository.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';

part 'map_controller.g.dart';

@riverpod
class MapController extends _$MapController {
  @override
  FutureOr<Set<Marker>> build() async {
    final cues = await ref.watch(cueRepositoryProvider).getCues();
    return _createMarkers(cues);
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cues = await ref.read(cueRepositoryProvider).getCues();
      return _createMarkers(cues);
    });
  }
}
