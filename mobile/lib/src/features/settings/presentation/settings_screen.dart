import 'package:flutter/material.dart';

import '../../../services/settings_service.dart';
import '../../../shared/main_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _distance;

  @override
  void initState() {
    super.initState();
    _distance = SettingsService.instance.candidateDistanceKm;
  }

  Future<void> _save() async {
    await SettingsService.instance.setCandidateDistanceKm(_distance);
    if (mounted) Navigator.pop(context);
  }

  String _distanceLabel(double value) {
    return value > 100 ? 'Any' : '${value.round()} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate search radius',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              min: 1,
              max: 101,
              divisions: 100,
              value: _distance,
              label: _distanceLabel(_distance),
              onChanged: (v) => setState(() => _distance = v),
            ),
            Text('Selected: ${_distanceLabel(_distance)}'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
