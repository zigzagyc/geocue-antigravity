import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocue/features/map/presentation/map_controller.dart';
import 'package:geocue/features/playback/service/proximity_service.dart';
import 'package:geocue/features/playback/service/playback_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Example: San Francisco
    zoom: 12,
  );

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Check if widget is still mounted before using ref
      if (!mounted) return;
      // Start monitoring proximity only if permission granted
      ref.read(proximityServiceProvider.notifier).startMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    final markersState = ref.watch(mapControllerProvider);
    final currentCue = ref.watch(playbackServiceProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mapControllerProvider.notifier).refreshCues(),
          ),
        ],
      ),
      body: Stack(
        children: [
          markersState.when(
            data: (markers) => GoogleMap(
              markers: markers,
              initialCameraPosition: _initialCameraPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading cues: $err')),
          ),
          if (currentCue != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 100, // Above FAB
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
                  title: Text(currentCue.title),
                  subtitle: const Text('Now Playing...'),
                  trailing: IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => ref.read(playbackServiceProvider.notifier).stop(),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-cue');
        },
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
