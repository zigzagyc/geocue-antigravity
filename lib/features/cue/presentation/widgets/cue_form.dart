import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/cue_model.dart';
import 'zone_selector.dart';

class CueForm extends StatefulWidget {
  final CueModel? initialCue;
  final bool isLoading;
  final Function({
    required String title,
    required String description,
    required bool isAudioMode,
    String? audioPath,
    String? textContent,
    required double lat,
    required double lng,
    required double radius,
    required String zoneType,
    List<Map<String, double>>? polygonPoints,
  }) onSave;

  const CueForm({
    super.key,
    this.initialCue,
    required this.isLoading,
    required this.onSave,
  });

  @override
  State<CueForm> createState() => _CueFormState();
}

class _CueFormState extends State<CueForm> {
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
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (widget.initialCue != null) {
      final cue = widget.initialCue!;
      _titleController.text = cue.title;
      _descriptionController.text = cue.description ?? '';
      
      // Determine mode based on cue data (simplified logic for now)
      // Ideally we should know if it was created from text or audio, but for now 
      // if it has an audioUrl, we might treat it as audio mode for editing ONLY if we supported re-recording.
      // For now, let's assume editing is flexible. 
      // If we are editing, we might want to default to the existing type.
      // But we don't store "isAudioMode" explicitly. 
      // Let's check if description matches text content logic or if it's separate.
      // For this implementation, let's default to Text unless we want to allow replacing audio.
      // If the user wants to replace audio, they can switch to audio mode.
      _isAudioMode = false; 
      
      _currentPosition = Position(
        longitude: cue.longitude,
        latitude: cue.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
        isMocked: false
      );
      _radius = cue.radius;
      _zoneType = cue.zoneType;
      _polygonPoints = cue.polygonPoints;
      _isLoadingLocation = false;
    } else {
      await _getCurrentLocation();
    }
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

  void _handleSave() {
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

    if (_isAudioMode) {
      if (_audioPath == null && widget.initialCue == null) {
        // If creating new, must have audio.
        // If editing, maybe we keep existing audio if not replaced?
        // For now, let's behave as if we need new audio if specific mode is selected?
        // Let's refine: If editing and user didn't record new audio, pass null audioPath.
      } else if (_audioPath == null && widget.initialCue != null) {
         // User didn't record new audio, maybe they just wanted to edit title/location?
         // In update logic, null audioPath might mean "keep existing".
      }
      
      // Wait, complex logic here. Let's simplify.
      // If mode is audio:
      // - New: Must record.
      // - Edit: Can record to replace. If not recorded, assume keep existing? 
      // BUT `onSave` interface separation:
      
      if (_audioPath == null && widget.initialCue == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please record audio first')));
          return;
      }
    } else {
      if (_descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content is required')));
        return;
      }
    }

    widget.onSave(
      title: _titleController.text,
      description: _descriptionController.text,
      isAudioMode: _isAudioMode,
      audioPath: _audioPath,
      textContent: _isAudioMode ? null : _descriptionController.text,
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
      radius: _radius,
      zoneType: _zoneType,
      polygonPoints: _polygonPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }

    // Only allow creation if we have location
    if (_currentPosition == null) {
       return Center(
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
       );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           TextField(
             controller: _titleController,
             decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
             enabled: !widget.isLoading,
           ),
           const SizedBox(height: 16),
           
           // Toggle for Text vs Audio
           SegmentedButton<bool>(
             segments: const [
               ButtonSegment(value: false, label: Text('Text'), icon: Icon(Icons.text_fields)),
               ButtonSegment(value: true, label: Text('Audio'), icon: Icon(Icons.mic)),
             ],
             selected: {_isAudioMode},
             onSelectionChanged: widget.isLoading ? null : (Set<bool> newSelection) {
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
               enabled: !widget.isLoading,
             ),
           ] else ...[
             Card(
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   children: [
                     if (widget.initialCue != null && _audioPath == null)
                       const Padding(
                         padding: EdgeInsets.only(bottom: 8.0),
                         child: Text('Current audio will be kept unless you record new.', style: TextStyle(fontStyle: FontStyle.italic)),
                       ),
                     Text(_isRecording ? 'Recording...' : 'Record Audio'),
                     const SizedBox(height: 16),
                     IconButton.filled(
                       onPressed: widget.isLoading ? null : (_isRecording ? _stopRecording : _startRecording),
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
               enabled: !widget.isLoading,
             ),
           ],
           
           const SizedBox(height: 24),
           const Text('Playback Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           ZoneSelector(
             initialLat: _currentPosition!.latitude,
             initialLng: _currentPosition!.longitude,
             initialRadius: _radius,
             initialZoneType: _zoneType,
             initialPolygonPoints: _polygonPoints,
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
             onPressed: widget.isLoading ? null : _handleSave,
             style: ElevatedButton.styleFrom(
               padding: const EdgeInsets.symmetric(vertical: 16),
             ),
             child: widget.isLoading 
               ? const CircularProgressIndicator() 
               : Text(widget.initialCue == null ? 'Save Cue' : 'Update Cue', style: const TextStyle(fontSize: 18)),
           ),
        ],
      ),
    );
  }
}
