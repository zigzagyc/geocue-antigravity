import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geocue/features/cue/domain/cue_model.dart';

part 'playback_service.g.dart';

@Riverpod(keepAlive: true)
class PlaybackService extends _$PlaybackService {
  final AudioPlayer _player = AudioPlayer();
  
  @override
  FutureOr<CueModel?> build() {
    ref.onDispose(() {
      _player.dispose();
    });
    return null;
  }

  Future<void> playCue(CueModel cue) async {
    try {
      state = AsyncValue.data(cue);
      await _player.setUrl(cue.audioUrl);
      await _player.play();
    } catch (e) {
      print('Playback Error: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AsyncValue.data(null);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
