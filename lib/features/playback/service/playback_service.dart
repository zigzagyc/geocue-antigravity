import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocue/features/cue/domain/cue_model.dart';

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
      print('PlaybackService Initialization Error: $e');
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
        print('Queue processing skipped: isPlaying=$_isPlaying, queueLength=${_queue.length}');
        return;
    }
    
    _isPlaying = true;
    final cue = _queue.removeAt(0);
    state = AsyncValue.data(cue);
    
    print('Attempting to play cue: ${cue.title} (Audio: ${cue.audioUrl.isNotEmpty})');

    try {
      if (cue.audioUrl.isNotEmpty) {
        // Voice Cue
        print('Playing audio from URL: ${cue.audioUrl}');
        await _player.setUrl(cue.audioUrl);
        await _player.play();
      } else {
        // Text Cue (TTS)
        final text = cue.description ?? cue.title;
        print('Speaking TTS: $text');
        await _tts.speak(text);
      }
    } catch (e) {
      print('Playback Error: $e');
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
