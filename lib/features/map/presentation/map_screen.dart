import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearhere/features/map/presentation/map_controller.dart';
import 'package:hearhere/features/playback/service/proximity_service.dart';
import 'package:hearhere/features/playback/service/playback_service.dart';
import 'package:hearhere/features/auth/presentation/auth_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with WidgetsBindingObserver {
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default: San Francisco
    zoom: 12,
  );

  GoogleMapController? _mapController;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocation();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed. Re-checking location permissions...');
      _requestLocationPermission();
    }
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_map_lat');
    final lng = prefs.getDouble('last_map_lng');
    final zoom = prefs.getDouble('last_map_zoom');

    if (lat != null && lng != null && zoom != null) {
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoom,
        );
      });
      // If controller is already available, move camera
      _mapController?.moveCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
    }
  }

  Future<void> _saveLocation(CameraPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_map_lat', position.target.latitude);
    await prefs.setDouble('last_map_lng', position.target.longitude);
    await prefs.setDouble('last_map_zoom', position.zoom);
  }

  Future<void> _requestLocationPermission() async {
    if (_isCheckingPermission) return;
    _isCheckingPermission = true;

    try {
      print('Requesting LocationWhenInUse permission...');
      var status = await Permission.locationWhenInUse.status;
      
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      print('LocationWhenInUse status: $status');
      
      if (!status.isGranted) {
        print('Location permission denied/permanently denied. Prompting user...');
        if (!mounted) return;
        
        // Show dialog to explain why we need permissions
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is required to show your position and play cues automatically. '
              'Please enable "Always Allow" or "While Using the App" in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (openSettings == true) {
          await openAppSettings();
        }
      } else {
        // Granted!
        // Then try to upgrade to "Always" for background playback
        print('Requesting LocationAlways permission...');
        final alwaysStatus = await Permission.locationAlways.request();
        print('LocationAlways status: $alwaysStatus');
        
        if (!mounted) return;
        print('Starting proximity monitoring...');
        ref.read(proximityServiceProvider.notifier).startMonitoring();
      }
    } finally {
      _isCheckingPermission = false;
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                 context.go('/login'); // Assuming '/login' is the route name
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          markersState.when(
            data: (markers) {
              return Stack(
                children: [
                   GoogleMap(
                    markers: markers,
                    initialCameraPosition: _initialCameraPosition,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                       _mapController = controller;
                        // Move to saved position if it was loaded after map creation
                       _mapController!.moveCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
                    },
                    onCameraMove: (position) {
                      _initialCameraPosition = position;
                    },
                    onCameraIdle: () {
                       _saveLocation(_initialCameraPosition);
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        'Debug: ${markers.length} markers',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  Text('Error loading cues: $err'),
                ],
              ),
            ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: () async {
              try {
                final position = await Geolocator.getCurrentPosition();
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 15,
                    ),
                  ),
                );
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Could not get location: $e')),
                   );
                }
              }
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_cue',
            onPressed: () {
              context.push('/create-cue');
            },
            child: const Icon(Icons.add_location_alt),
          ),
        ],
      ),
    );
  }
}
