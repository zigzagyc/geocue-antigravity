import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocue/features/cue/domain/cue_model.dart';

part 'playback_service.g.dart';

@Riverpod(keepAlive: true)
class PlaybackService extends _$PlaybackService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
  @override
  FutureOr<CueModel?> build() async {
    // Configure TTS for iOS
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
    ]);
    await _tts.awaitSpeakCompletion(true);

    ref.onDispose(() {
      _player.dispose();
      _tts.stop();
    });
    return null;
  }

  Future<void> playCue(CueModel cue) async {
    try {
      state = AsyncValue.data(cue);
      // Stop any previous playback
      await stop();

      if (cue.audioUrl.isNotEmpty) {
        // Voice Cue
        await _player.setUrl(cue.audioUrl);
        await _player.play();
      } else {
        // Text Cue (TTS)
        await _tts.speak(cue.description ?? cue.title);
      }
    } catch (e) {
      print('Playback Error: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
    await _tts.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
    state = const AsyncValue.data(null);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
