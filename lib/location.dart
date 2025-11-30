import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationCityPage extends StatefulWidget {
  const LocationCityPage({super.key});

  @override
  State<LocationCityPage> createState() => _LocationCityPageState();
}

class _LocationCityPageState extends State<LocationCityPage> {
  String _status = 'Press the button to get location';
  String? _city;
  double? _latitude;
  double? _longitude;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Optionally auto-get on start:
    // _determinePositionAndCity();
  }

  Future<void> _determinePositionAndCity() async {
    setState(() {
      _loading = true;
      _status = 'Checking permissions...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Location permissions are denied';
          _loading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _status =
              'Location permissions are permanently denied, open app settings to enable.';
          _loading = false;
        });
        await Geolocator.openAppSettings();
        return;
      }

      setState(() {
        _status = 'Getting current position...';
      });

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 20),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      setState(() {
        _status = 'Reverse geocoding...';
      });

      // Reverse geocode to placemarks
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );

      // Choose the most informative placemark
      Placemark place = placemarks.isNotEmpty ? placemarks.first : Placemark();

      String cityCandidate =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea ??
          place.name ??
          'Unknown';

      setState(() {
        _city = cityCandidate;
        _status = 'Success';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _loading = false;
      });
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-', overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show estimated city from environment (Lahore) as initial hint
    const String estimatedCity = 'Lahore, Punjab, Pakistan (estimated)';

    return Scaffold(
      appBar: AppBar(title: const Text('Get Current City')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Estimated city from environment:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              estimatedCity,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Divider(height: 24),

            _infoRow('Status', _status),
            _infoRow('City', _city ?? '-'),
            _infoRow('Latitude', _latitude?.toStringAsFixed(6)),
            _infoRow('Longitude', _longitude?.toStringAsFixed(6)),

            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _loading ? null : _determinePositionAndCity,
              icon: const Icon(Icons.my_location),
              label: const Text('Get Current City'),
            ),

            const SizedBox(height: 12),
            Text(
              'Tip: If permissions are denied, allow location for the app in system settings.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
