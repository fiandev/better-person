import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/material.dart';

import '../../controllers/prayer_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../utils/location_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  adhan.CalculationMethod _method = adhan.CalculationMethod.muslim_world_league;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final location = await LocationService.getLocation();
    final setting = SettingController().getCurrentSetting();
    final method = adhan.CalculationMethod.values.firstWhere(
      (value) => value.name == setting.prayerCalculationMethod,
      orElse: () => adhan.CalculationMethod.muslim_world_league,
    );
    if (!mounted) return;
    setState(() {
      _latitudeController.text = location.latitude.toString();
      _longitudeController.text = location.longitude.toString();
      _method = method;
      _loading = false;
    });
  }

  String? _coordinateValidator(String? value, double min, double max) {
    final coordinate = double.tryParse(value?.trim() ?? '');
    if (coordinate == null || coordinate < min || coordinate > max) {
      return 'Enter a value from $min to $max.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await LocationService.saveLocation(
        double.parse(_latitudeController.text.trim()),
        double.parse(_longitudeController.text.trim()),
      );
      final controller = SettingController();
      await controller.ensureSettingsExist();
      await controller.updateFields(controller.getCurrentSetting().id, {
        'prayerCalculationMethod': _method.name,
      });
      await PrayerController().recalculateTodayPrayerTimes();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prayer settings saved.')));
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save prayer settings: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _methodLabel(adhan.CalculationMethod method) => method.name
      .split('_')
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Enter coordinates for the place where you pray. These stay on this device.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _coordinateValidator(value, -90, 90),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _coordinateValidator(value, -180, 180),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<adhan.CalculationMethod>(
              initialValue: _method,
              decoration: const InputDecoration(
                labelText: 'Calculation method',
                border: OutlineInputBorder(),
              ),
              items: adhan.CalculationMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(
                        _methodLabel(method),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (method) {
                if (method != null) setState(() => _method = method);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save prayer settings'),
            ),
          ],
        ),
      ),
    );
  }
}
