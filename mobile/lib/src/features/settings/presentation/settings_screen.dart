import 'package:flutter/material.dart';

import '../../../services/settings_service.dart';
import '../../../shared/main_app_bar.dart';
import '../../../localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _distance;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _distance = SettingsService.instance.candidateDistanceKm;
    _languageCode = SettingsService.instance.locale.languageCode;
  }

  Future<void> _save() async {
    await SettingsService.instance.setCandidateDistanceKm(_distance);
    await SettingsService.instance.setLocale(_languageCode);
    if (mounted) Navigator.pop(context);
  }

  String _distanceLabel(double value) {
    return value > 100 ? context.l10n.translate('any') : '${value.round()} km';
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
              context.l10n.translate('candidateRadius'),
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
            Text('${context.l10n.translate('selected')}: ${_distanceLabel(_distance)}'),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'uk', child: Text('Українська')),
              ],
              onChanged: (v) => setState(() => _languageCode = v ?? 'en'),
              decoration: InputDecoration(labelText: context.l10n.translate('languages')),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _save,
                child: Text(context.l10n.translate('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
