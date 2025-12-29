import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'create_cue_controller.dart';
import 'widgets/zone_selector.dart';

class CreateCueScreen extends ConsumerStatefulWidget {
  const CreateCueScreen({super.key});

  @override
  ConsumerState<CreateCueScreen> createState() => _CreateCueScreenState();
}

class _CreateCueScreenState extends ConsumerState<CreateCueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  bool _isAudioMode = false;

  // Location & Zone State
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  double _radius = 50.0;
  String _zoneType = 'circle';
  List<Map<String, double>>? _polygonPoints;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isLoadingLocation = false;
          });
        }
      } else {
        if (mounted) {
           setState(() => _isLoadingLocation = false);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        debugPrint('Error getting location: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/cue_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _audioPath = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording Error: $e')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stop Error: $e')));
    }
  }

  Future<void> _saveCue() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    // specific validation for polygon
    if (_zoneType == 'polygon' && (_polygonPoints == null || _polygonPoints!.length < 3)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please draw a valid polygon zone (3+ points)')));
       return;
    }

    try {
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;

      if (_isAudioMode) {
        if (_audioPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please record audio first')));
          return;
        }
        await ref.read(createCueControllerProvider.notifier).createCueFromAudio(
          title: _titleController.text,
          description: _descriptionController.text,
          audioFilePath: _audioPath!,
          language: 'en',
          lat: lat,
          lng: lng,
          radius: _radius,
          zoneType: _zoneType,
          polygonPoints: _polygonPoints,
        );
      } else {
        if (_descriptionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content is required')));
          return;
        }
        await ref.read(createCueControllerProvider.notifier).createCueFromText(
          title: _titleController.text,
          description: _descriptionController.text,
          textContent: _descriptionController.text,
          language: 'en',
          lat: lat,
          lng: lng,
          radius: _radius,
          zoneType: _zoneType,
          polygonPoints: _polygonPoints,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createCueControllerProvider, (previous, state) {
       if (state.hasError) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
       }
       if (!state.isLoading && !state.hasError && previous?.isLoading == true) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cue Created!')));
         context.pop();
       }
    });

    final state = ref.watch(createCueControllerProvider);
    final isLoading = state.isLoading;

    if (_isLoadingLocation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Only allow creation if we have location
    if (_currentPosition == null) {
       return Scaffold(
         appBar: AppBar(title: const Text('Create New Cue')),
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Text('Location needed to place cue.'),
               ElevatedButton(
                 onPressed: _getCurrentLocation,
                 child: const Text('Retry Location'),
               )
             ],
           ),
         ),
       );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Cue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             TextField(
               controller: _titleController,
               decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
               enabled: !isLoading,
             ),
             const SizedBox(height: 16),
             
             // Toggle for Text vs Audio
             SegmentedButton<bool>(
               segments: const [
                 ButtonSegment(value: false, label: Text('Text'), icon: Icon(Icons.text_fields)),
                 ButtonSegment(value: true, label: Text('Audio'), icon: Icon(Icons.mic)),
               ],
               selected: {_isAudioMode},
               onSelectionChanged: isLoading ? null : (Set<bool> newSelection) {
                 setState(() {
                   _isAudioMode = newSelection.first;
                 });
               },
             ),
             const SizedBox(height: 16),
             
             if (!_isAudioMode) ...[
               TextField(
                 controller: _descriptionController,
                 decoration: const InputDecoration(
                   labelText: 'Text Content',
                   hintText: 'Enter text to be converted to speech...',
                   border: OutlineInputBorder(),
                 ),
                 maxLines: 5,
                 enabled: !isLoading,
               ),
             ] else ...[
               Card(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     children: [
                       Text(_isRecording ? 'Recording...' : 'Record Audio'),
                       const SizedBox(height: 16),
                       IconButton.filled(
                         onPressed: isLoading ? null : (_isRecording ? _stopRecording : _startRecording),
                         icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                         iconSize: 48,
                         color: _isRecording ? Colors.red : null,
                       ),
                       if (_audioPath != null) ...[
                         const SizedBox(height: 8),
                         const Text('Audio captured!', style: TextStyle(color: Colors.green)),
                       ],
                     ],
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               TextField(
                 controller: _descriptionController,
                 decoration: const InputDecoration(
                   labelText: 'Description (Optional)',
                   border: OutlineInputBorder(),
                 ),
                 maxLines: 2,
                 enabled: !isLoading,
               ),
             ],
             
             const SizedBox(height: 24),
             const Text('Playback Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             ZoneSelector(
               initialLat: _currentPosition!.latitude,
               initialLng: _currentPosition!.longitude,
               onZoneChanged: (radius, type, points) {
                 setState(() {
                   _radius = radius;
                   _zoneType = type;
                   _polygonPoints = points;
                 });
               },
             ),

             const SizedBox(height: 24),
             
             ElevatedButton(
               onPressed: isLoading ? null : _saveCue,
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 16),
               ),
               child: isLoading 
                 ? const CircularProgressIndicator() 
                 : const Text('Save Cue', style: TextStyle(fontSize: 18)),
             ),
          ],
        ),
      ),
    );
  }
}
