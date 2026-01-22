import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hearhere/features/admin/presentation/admin_controller.dart';
import 'package:hearhere/features/cue/presentation/widgets/zone_selector.dart';
import 'package:geolocator/geolocator.dart';

class CreateLockedAreaScreen extends ConsumerStatefulWidget {
  const CreateLockedAreaScreen({super.key});

  @override
  ConsumerState<CreateLockedAreaScreen> createState() => _CreateLockedAreaScreenState();
}

class _CreateLockedAreaScreenState extends ConsumerState<CreateLockedAreaScreen> {
  final _reasonController = TextEditingController();
  
  double _lat = 0;
  double _lng = 0;
  double _radius = 50.0;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Assuming permission already granted from previous usage, otherwise standard check
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      // Fallback
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _submit() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a reason')));
      return;
    }

    ref.read(adminControllerProvider.notifier).createLockedArea(
      latitude: _lat,
      longitude: _lng,
      radius: _radius,
      reason: _reasonController.text,
    );
    
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Area Locked Successfully')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Lock New Area')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             const Text('Select area to lock. No cues can be created in this zone.', 
               style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
             const SizedBox(height: 16),
             TextField(
               controller: _reasonController,
               decoration: const InputDecoration(
                 labelText: 'Reason for locking',
                 hintText: 'e.g. Restricted Site, Private Property',
                 border: OutlineInputBorder(),
               ),
             ),
             const SizedBox(height: 16),
             const Text('Zone Config', style: TextStyle(fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             // reusing ZoneSelector, ignoring polygon mode output since backend only supports radius for locked areas initially
             ZoneSelector(
               initialLat: _lat,
               initialLng: _lng,
               initialRadius: _radius,
               initialZoneType: 'circle',
               onZoneChanged: (lat, lng, radius, type, points) {
                 setState(() {
                   _lat = lat;
                   _lng = lng;
                   _radius = radius;
                 });
               },
             ),
             const SizedBox(height: 24),
             if (_radius > 1000)
               const Text('Warning: Large radius selected.', style: TextStyle(color: Colors.orange)),
             
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: _submit,
                 icon: const Icon(Icons.lock),
                 label: const Text('Lock This Area'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.all(16),
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }
}
