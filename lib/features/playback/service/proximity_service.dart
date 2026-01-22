import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hearhere/features/cue/data/cue_repository.dart';
import 'package:hearhere/features/cue/domain/cue_model.dart';
import 'package:hearhere/features/playback/service/playback_service.dart';

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

    if (_positionSubscription != null) return;

    LocationSettings locationSettings;
    
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    // Immediate check on startup
    Geolocator.getCurrentPosition().then((position) {
      _checkProximity(position);
    }).catchError((e) {
      // Handle error
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      _checkProximity(position);
    }, onError: (e) {
      // Handle error
    });
  }

  Future<void> _checkProximity(Position position) async {
    final cues = await ref.read(cueRepositoryProvider).getCues();
    final List<CueModel> cuesInRange = [];
    
    // 1. Collect all cues currently in range that haven't been played
    for (final cue in cues) {
      if (_playedCueIds.contains(cue.id)) continue;

      bool isInRange = false;

      if (cue.zoneType == 'polygon' && cue.polygonPoints != null && cue.polygonPoints!.isNotEmpty) {
        isInRange = _isPointInPolygon(
          position.latitude, 
          position.longitude, 
          cue.polygonPoints!
        );
      } else {
        // Default to circle (or fallback if polygon data missing)
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          cue.latitude,
          cue.longitude,
        );
        isInRange = distance <= (cue.radius > 0 ? cue.radius : ProximityService.proximityThreshold);
      }

      if (isInRange) {
        cuesInRange.add(cue);
      }
    }

    if (cuesInRange.isEmpty) return;

    // 2. Sort by creation time (descending: newest first)
    cuesInRange.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 3. Play ONLY the most recent one
    final newestCue = cuesInRange.first;
    _triggerPlayback(newestCue);

    // 4. Mark ALL detected cues as "played/visited" so they don't trigger 
    // immediately after if the user stays in the zone.
    for (final cue in cuesInRange) {
      if (cue.id != newestCue.id) {
        _playedCueIds.add(cue.id);
      }
    }
  }

  // Ray Casting Algorithm to check if point is in polygon
  bool _isPointInPolygon(double lat, double lng, List<Map<String, double>> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i]['lat']!;
      final yi = polygon[i]['lng']!;
      final xj = polygon[j]['lat']!;
      final yj = polygon[j]['lng']!;

      final intersect = ((yi > lng) != (yj > lng)) &&
          (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  void _triggerPlayback(CueModel cue) {
    if (_playedCueIds.contains(cue.id)) {
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
