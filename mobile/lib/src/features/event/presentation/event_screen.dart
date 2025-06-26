import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../env.dart';
import '../../../models/event_response.dart';
import '../../../models/current_user_response.dart';
import '../../../services/event_service.dart';
import '../../../services/user_service.dart';

class EventScreen extends StatefulWidget {
  final int eventId;

  const EventScreen({super.key, required this.eventId});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  EventResponse? _event;
  int? _currentUserId;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final eventRes = await EventService.instance.getEvent(widget.eventId);
      final userRes = await UserService.instance.getCurrentUser();
      _event = EventResponse.fromJson(eventRes.data);
      _currentUserId = CurrentUserResponse.fromJson(userRes.data).id;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isOwner => _event != null && _currentUserId == _event!.hostId;

  bool get _isParticipant =>
      _event != null && _event!.participantIds.contains(_currentUserId);

  Future<void> _join() async {
    setState(() => _actionLoading = true);
    try {
      await EventService.instance.joinEvent(_event!.id);
      await _loadData();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _leave() async {
    setState(() => _actionLoading = true);
    try {
      await EventService.instance.leaveEvent(_event!.id);
      await _loadData();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _actionLoading = true);
    try {
      await EventService.instance.deleteEvent(_event!.id);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Widget _buildMap() {
    final point = LatLng(_event!.latitude, _event!.longitude);
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(initialCenter: point, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: mapTileUrl,
            userAgentPackageName: 'com.example.pawconnect',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: point,
                child: Icon(
                  Icons.location_pin,
                  color: _isOwner ? Colors.amber : Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_event == null) {
      return const Center(child: Text('Event not found'));
    }

    final dateText = DateFormat('yMMMd – HH:mm').format(_event!.eventDateTime);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMap(),
            const SizedBox(height: 16),
            Text(
              _event!.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(dateText),
            const SizedBox(height: 8),
            Text(
              '${_event!.latitude.toStringAsFixed(5)}, '
              '${_event!.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_event!.description != null && _event!.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_event!.description!),
              ),
            const SizedBox(height: 24),
            if (_isOwner)
              ElevatedButton.icon(
                onPressed: _actionLoading ? null : _delete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Event'),
              )
            else if (_isParticipant)
              ElevatedButton.icon(
                onPressed: _actionLoading ? null : _leave,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Leave Event'),
              )
            else
              ElevatedButton.icon(
                onPressed: _actionLoading ? null : _join,
                icon: const Icon(Icons.group_add),
                label: const Text('Join Event'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: _buildBody(),
    );
  }
}
