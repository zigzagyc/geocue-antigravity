import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ZoneSelector extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final double initialRadius;
  final String initialZoneType;
  final List<Map<String, double>>? initialPolygonPoints;
  final Function(double lat, double lng, double radius, String zoneType, List<Map<String, double>>? polygonPoints) onZoneChanged;

  const ZoneSelector({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.initialRadius = 50.0,
    this.initialZoneType = 'circle',
    this.initialPolygonPoints,
    required this.onZoneChanged,
  });

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {}; // For drawing feedback

  late double _lat;
  late double _lng;
  late double _radius;
  late bool _isPolygonMode;
  final List<LatLng> _polygonPoints = [];
  GoogleMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _radius = widget.initialRadius;
    _isPolygonMode = widget.initialZoneType == 'polygon';
    if (widget.initialPolygonPoints != null) {
      _polygonPoints.addAll(widget.initialPolygonPoints!.map((p) => LatLng(p['lat']!, p['lng']!)));
    }
    
    // Defer the initial update to after build to avoid "setState during build" errors if called synchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isPolygonMode) {
          _updatePolygon();
        } else {
          _updateCircle();
        }
    });
  }

  void _updateCircle() {
    setState(() {
      _circles.clear();
      _markers.clear(); // Clear other markers
      if (!_isPolygonMode) {
        _circles.add(
          Circle(
            circleId: const CircleId('zone_circle'),
            center: LatLng(_lat, _lng),
            radius: _radius,
            fillColor: Colors.blue.withValues(alpha: 0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        );
        // Center marker is now static in the UI center, so we don't necessarily need a map marker unless we want to persist it.
        // Actually, for "move map to select", usually there's a static pin. 
        // But let's keep a marker if we want, OR just rely on the circle. 
        // Let's rely on the circle and maybe a center icon overlay.
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
              fillColor: Colors.purple.withValues(alpha: 0.2),
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
      widget.onZoneChanged(_lat, _lng, _radius, 'polygon', points);
    } else {
      widget.onZoneChanged(_lat, _lng, _radius, 'circle', null);
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
      _polygons.clear();
      _polylines.clear();
      _markers.clear();
    });
    _notifyParent(); // Update parent with empty
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
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.initialLat, widget.initialLng),
                    zoom: 17,
                  ),
                  markers: _markers,
                  circles: _circles,
                  polygons: _polygons,
                  polylines: _polylines,
                  onTap: _onMapTap,
                  myLocationEnabled: false, 
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (position) {
                    if (!_isPolygonMode) {
                      _lat = position.target.latitude;
                      _lng = position.target.longitude;
                       // We don't setState here to avoid lag, but we update the internal state
                       // visual circle is static in center? No, circle moves with map? 
                       // Actually, if we want "screen center" selection, the circle should stay at screen center.
                       // But the GoogleMap `circles` set is geolocated. So we MUST update it.
                       // Updating circle on every frame might be expensive. 
                       // Standard pattern: Marker fixed at center of screen (Overlay), map moves under it.
                    }
                  },
                  onCameraIdle: () {
                     if (!_isPolygonMode) {
                       _updateCircle(); // Update the geolocated circle when dragging stops
                     }
                  },
                  zoomControlsEnabled: true,
                ),
              ),
              // Center Marker Overlay for Circle Mode
              if (!_isPolygonMode)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30), // Lift up slightly to match pin point
                    child: Icon(Icons.location_on, size: 40, color: Colors.blue),
                  ),
                ),
                
              // Recenter Button
              Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.center_focus_strong, color: Colors.black),
                  onPressed: () {
                     _mapController?.animateCamera(
                       CameraUpdate.newLatLng(LatLng(widget.initialLat, widget.initialLng))
                     );
                  },
                ),
              ),
            ],
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
