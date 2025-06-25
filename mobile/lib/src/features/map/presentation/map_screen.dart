import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../env.dart';
import '../../../models/event_response.dart';
import '../../../services/event_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  final List<EventResponse> _events = [];
  int? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        _userLocation = LatLng(pos.latitude, pos.longitude);
        final res = await EventService.instance.searchEvents(
          latitude: pos.latitude,
          longitude: pos.longitude,
          radiusKm: 3.218688,
        );
        _events
          ..clear()
          ..addAll(
            (res.data as List<dynamic>).map(
              (e) => EventResponse.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildInfoCard() {
    if (_events.isEmpty) return const SizedBox.shrink();
    final event = _events.firstWhere(
      (e) => e.id == _selectedId,
      orElse: () => _events[0],
    );
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(DateFormat('yMMMd – HH:mm').format(event.eventDateTime)),
            const SizedBox(height: 4),
            Text(
              '${event.latitude.toStringAsFixed(5)}, ${event.longitude.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.pushNamed(
                    'event',
                    pathParameters: {'id': event.id.toString()},
                  );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return _events
        .map(
          (e) => Marker(
            width: 40,
            height: 40,
            point: LatLng(e.latitude, e.longitude),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedId = e.id;
                });
              },
              child: Icon(
                Icons.location_pin,
                color: _selectedId == e.id ? Colors.green : Colors.red,
                size: 40,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_userLocation == null) {
      body = const Center(child: Text('Location unavailable'));
    } else {
      body = Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _userLocation!, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: mapTileUrl,
                userAgentPackageName: 'com.example.pawconnect',
                // tileProvider: NetworkTileProvider(
                //   headers: const {'User-Agent': 'PawConnectApp/1.0 (Android)'},
                // ),
              ),
              RichAttributionWidget(
                attributions: [
                  // Suggested attribution for the OpenStreetMap public tile server
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
              const CurrentLocationLayer(),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          if (_selectedId != null)
            Positioned(left: 0, right: 0, bottom: 0, child: _buildInfoCard()),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Events')),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('event-create'),
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
