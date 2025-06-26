import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../env.dart';
import '../../../models/event_response.dart';
import '../../../services/event_service.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _location;

  DateTime? _date;
  TimeOfDay? _time;

  bool _loading = false;
  String? _titleError;
  String? _dateError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _setDeviceLocation();
  }

  Future<void> _setDeviceLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _location = LatLng(pos.latitude, pos.longitude);
          _mapController.move(_location!, 15);
        });
      }
    } catch (_) {}
  }

  bool _validate() {
    setState(() {
      _titleError = titleController.text.isEmpty ? 'Required' : null;
      _dateError = (_date == null || _time == null) ? 'Required' : null;
      _locationError = _location == null ? 'Required' : null;
    });
    return [
      _titleError,
      _dateError,
      _locationError,
    ].every((e) => e == null);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _date = date;
      _time = time;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final dateTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    setState(() => _loading = true);
    try {
      final res = await EventService.instance.createEvent({
        'title': titleController.text,
        'description': descriptionController.text,
        'eventDateTime': dateTime.toIso8601String(),
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
      });
      if (!mounted) return;
      final event = EventResponse.fromJson(res.data);
      context.pushReplacementNamed(
        'event',
        pathParameters: {'id': event.id.toString()},
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Creation failed: $message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Creation failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = (_date == null || _time == null)
        ? 'Select date & time'
        : DateFormat('yMMMd HH:mm').format(
            DateTime(
              _date!.year,
              _date!.month,
              _date!.day,
              _time!.hour,
              _time!.minute,
            ),
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title', errorText: _titleError),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration:
                    InputDecoration(labelText: 'Date & Time', errorText: _dateError),
                child: Text(dateText),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: Theme.of(context).inputDecorationTheme.labelStyle),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _location ?? const LatLng(0, 0),
                      initialZoom: 15,
                      onTap: (_, point) => setState(() => _location = point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: mapTileUrl,
                        userAgentPackageName: 'com.example.pawconnect',
                      ),
                      if (_location != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: _location!,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _setDeviceLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use current location'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

