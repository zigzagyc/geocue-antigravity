import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocue/features/cue/data/cue_repository.dart';
import 'package:geocue/features/cue/domain/cue_model.dart';
import 'package:geocue/features/playback/service/playback_service.dart';

part 'proximity_service.g.dart';

@Riverpod(keepAlive: true)
class ProximityService extends _$ProximityService {
  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _playedCueIds = {};
  static const double proximityThreshold = 50.0; // meters

  @override
  void build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });
  }

  void startMonitoring() {
    print('ProximityService: startMonitoring called. Subscription exists: ${_positionSubscription != null}');
    if (_positionSubscription != null) return;

    LocationSettings locationSettings;
    
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      print('ProximityService: Using AppleSettings');
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      print('ProximityService: Using standard LocationSettings');
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    // Immediate check on startup
    print('ProximityService: Getting initial position...');
    Geolocator.getCurrentPosition().then((position) {
      print('ProximityService: Initial position received: ${position.latitude}, ${position.longitude}');
      _checkProximity(position);
    }).catchError((e) {
      print('Error getting initial position: $e');
    });

    print('ProximityService: Subscribing to position stream...');
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      print('ProximityService: Stream position update: ${position.latitude}, ${position.longitude}');
      _checkProximity(position);
    }, onError: (e) {
      print('ProximityService: Stream Error: $e');
    });
  }

  Future<void> _checkProximity(Position position) async {
    final cues = await ref.read(cueRepositoryProvider).getCues();
    
    for (final cue in cues) {
      if (_playedCueIds.contains(cue.id)) continue;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        cue.latitude,
        cue.longitude,
      );

      print('Proximity Check: ${cue.title} is ${distance.toStringAsFixed(1)}m away (Threshold: $proximityThreshold)');

      if (distance <= proximityThreshold) {
        print('!!! TRIGGERING PLAYBACK for ${cue.title} !!!');
        _triggerPlayback(cue);
      }
    }
  }

  void _triggerPlayback(CueModel cue) {
    if (_playedCueIds.contains(cue.id)) {
        print('Skipping ${cue.title}, already played.');
        return;
    }
    _playedCueIds.add(cue.id);
    ref.read(playbackServiceProvider.notifier).playCue(cue);
  }

  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
