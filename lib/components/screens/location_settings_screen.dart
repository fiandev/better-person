import 'package:adhan/adhan.dart' as adhan;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  final _mapController = MapController();
  final _manualExpansionController = ExpansibleController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  LatLng _selectedLocation = const LatLng(0, 0);
  adhan.CalculationMethod _method = adhan.CalculationMethod.muslim_world_league;
  bool _loading = true;
  bool _saving = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _manualExpansionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await LocationService.getLocation();
      final setting = SettingController().getCurrentSetting();
      final method = adhan.CalculationMethod.values.firstWhere(
        (value) => value.name == setting.prayerCalculationMethod,
        orElse: () => adhan.CalculationMethod.muslim_world_league,
      );
      if (!mounted) return;
      final coords = LatLng(location.latitude, location.longitude);
      setState(() {
        _selectedLocation = coords;
        _latitudeController.text = coords.latitude.toStringAsFixed(5);
        _longitudeController.text = coords.longitude.toStringAsFixed(5);
        _method = method;
      });
    } catch (_) {
      // Fall back to default coordinates if loading fails.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _latitudeController.text = point.latitude.toStringAsFixed(5);
    _longitudeController.text = point.longitude.toStringAsFixed(5);
  }

  void _onManualCoordinateChanged() {
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    if (lat == null || !lat.isFinite || lat < -90 || lat > 90) return;
    if (lng == null || !lng.isFinite || lng < -180 || lng > 180) return;
    final next = LatLng(lat, lng);
    setState(() {
      _selectedLocation = next;
    });
    if (_mapReady) {
      _mapController.move(next, _mapController.camera.zoom);
    }
  }

  String? _coordinateValidator(String? value, double min, double max) {
    final coordinate = double.tryParse(value?.trim() ?? '');
    if (coordinate == null ||
        !coordinate.isFinite ||
        coordinate < min ||
        coordinate > max) {
      return 'Enter a value from $min to $max.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? true)) {
      if (!_manualExpansionController.isExpanded) {
        _manualExpansionController.expand();
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await LocationService.saveLocation(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Tap the map to set the place where you pray. Coordinates stay on this device.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 13.0,
                    onMapReady: () => _mapReady = true,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.better_person',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.location_on,
                            size: 40,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selected: ${_selectedLocation.latitude.toStringAsFixed(5)}, '
              '${_selectedLocation.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              controller: _manualExpansionController,
              title: const Text('Enter coordinates manually'),
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8, bottom: 12),
              children: [
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
                  onChanged: (_) => _onManualCoordinateChanged(),
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
                  onChanged: (_) => _onManualCoordinateChanged(),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
