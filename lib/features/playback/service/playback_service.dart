import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';

part 'playback_service.g.dart';

@Riverpod(keepAlive: true)
class PlaybackService extends _$PlaybackService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
// Queue to hold cues waiting to be played
  final List<CueModel> _queue = [];
  bool _isPlaying = false;

  final Completer<void> _initCompleter = Completer<void>();

  @override
  FutureOr<CueModel?> build() async {
    try {
      // Configure TTS for iOS
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
      await _tts.awaitSpeakCompletion(true);
      
      // Set up completion handlers
      _tts.setCompletionHandler(() {
        _onPlaybackCompleted();
      });
      
      // Listen for audio player completion
      _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _onPlaybackCompleted();
        }
      });

      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(e);
      }
    }

    ref.onDispose(() {
      _player.dispose();
      _tts.stop();
    });
    return null;
  }

  Future<void> playCue(CueModel cue) async {
    // Wait for initialization to complete
    if (!_initCompleter.isCompleted) {
      await _initCompleter.future;
    }
    _queue.add(cue);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isPlaying || _queue.isEmpty) {
        return;
    }
    
    _isPlaying = true;
    final cue = _queue.removeAt(0);
    state = AsyncValue.data(cue);
    
    try {
      if (cue.audioUrl.isNotEmpty) {
        // Voice Cue
        await _player.setUrl(cue.audioUrl);
        await _player.play();
      } else {
        // Text Cue (TTS)
        final text = cue.description ?? cue.title;
        
        // Map short codes to full locales for better TTS quality
        String locale = cue.language;
        switch (cue.language) {
          case 'zh': locale = 'zh-CN'; break;
          case 'en': locale = 'en-US'; break; 
          case 'es': locale = 'es-ES'; break;
          case 'fr': locale = 'fr-FR'; break;
          case 'de': locale = 'de-DE'; break;
          case 'ja': locale = 'ja-JP'; break;
          case 'ko': locale = 'ko-KR'; break;
        }
        
        await _tts.setLanguage(locale);
        await _tts.speak(text);
      }
    } catch (e) {
      _onPlaybackCompleted(); // Ensure queue continues even on error
    }
  }

  void _onPlaybackCompleted() {
    _isPlaying = false;
    state = const AsyncValue.data(null);
    _processQueue();
  }

  Future<void> pause() async {
    await _player.pause();
    await _tts.pause();
  }

  Future<void> stop() async {
    _queue.clear(); // Clear queue on stop
    _isPlaying = false;
    await _player.stop();
    await _tts.stop();
    state = const AsyncValue.data(null);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
