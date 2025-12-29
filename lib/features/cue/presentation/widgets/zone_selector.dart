import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class ZoneSelector extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double radius, String zoneType, List<Map<String, double>>? polygonPoints) onZoneChanged;

  const ZoneSelector({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onZoneChanged,
  });

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {}; // For drawing feedback

  bool _isPolygonMode = false;
  double _radius = 50.0;
  final List<LatLng> _polygonPoints = [];
  
  @override
  void initState() {
    super.initState();
    _updateCircle();
  }

  void _updateCircle() {
    setState(() {
      _circles.clear();
      if (!_isPolygonMode) {
        _circles.add(
          Circle(
            circleId: const CircleId('zone_circle'),
            center: LatLng(widget.initialLat, widget.initialLng),
            radius: _radius,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        );
        // Also update marker center
        _markers.clear();
        _markers.add(
           Marker(
             markerId: const MarkerId('center'),
             position: LatLng(widget.initialLat, widget.initialLng),
           ),
        );
      }
    });
    _notifyParent();
  }

  void _updatePolygon() {
    setState(() {
      _polygons.clear();
      _polylines.clear();
      _markers.clear();

      if (_isPolygonMode) {
        // Draw markers at each point
        for (int i = 0; i < _polygonPoints.length; i++) {
          _markers.add(
            Marker(
              markerId: MarkerId('point_$i'),
              position: _polygonPoints[i],
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }

        // Draw polyline for feedback while drawing
        if (_polygonPoints.isNotEmpty) {
           _polylines.add(
            Polyline(
              polylineId: const PolylineId('drawing_line'),
              points: [..._polygonPoints, _polygonPoints.first], // Close loop for visual
              color: Colors.purple,
              patterns: [PatternItem.dash(10), PatternItem.gap(5)],
              width: 2,
            ),
          );
        }

        // Create polygon if enough points
        if (_polygonPoints.length >= 3) {
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('zone_polygon'),
              points: _polygonPoints,
              fillColor: Colors.purple.withOpacity(0.2),
              strokeColor: Colors.purple,
              strokeWidth: 2,
            ),
          );
        }
      }
    });
    _notifyParent();
  }

  void _notifyParent() {
    if (_isPolygonMode) {
      final points = _polygonPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
      widget.onZoneChanged(_radius, 'polygon', points);
    } else {
      widget.onZoneChanged(_radius, 'circle', null);
    }
  }

  void _onMapTap(LatLng point) {
    if (_isPolygonMode) {
      setState(() {
        _polygonPoints.add(point);
      });
      _updatePolygon();
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
    });
    _updatePolygon();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Controls
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Circle'), icon: Icon(Icons.circle_outlined)),
                  ButtonSegment(value: true, label: Text('Freestyle'), icon: Icon(Icons.draw)),
                ],
                selected: {_isPolygonMode},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isPolygonMode = newSelection.first;
                    // Reset or refresh view
                    if (_isPolygonMode) {
                      _updatePolygon();
                    } else {
                      _updateCircle();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Contextual Controls
        if (!_isPolygonMode) ...[
          Row(
            children: [
              const Text('Radius: '),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: '${_radius.round()}m',
                  onChanged: (val) {
                    setState(() {
                      _radius = val;
                      _updateCircle();
                    });
                  },
                ),
              ),
              Text('${_radius.round()}m'),
            ],
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tap map to draw points', style: TextStyle(fontStyle: FontStyle.italic)),
              TextButton.icon(
                onPressed: _clearPolygon,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],

        // Map
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialLat, widget.initialLng),
                zoom: 17,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _markers,
              circles: _circles,
              polygons: _polygons,
              polylines: _polylines,
              onTap: _onMapTap,
              myLocationEnabled: false, // We use the fixed center for creation
              zoomControlsEnabled: true,
            ),
          ),
        ),
        if (_isPolygonMode && _polygonPoints.length < 3)
           const Padding(
             padding: EdgeInsets.only(top: 8.0),
             child: Text('Add at least 3 points to form a zone.', style: TextStyle(color: Colors.orange)),
           ),
      ],
    );
  }
}
