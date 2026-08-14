import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(9.0300, 38.7400); // Addis Ababa

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pick Location',
          style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _currentPosition = position.target;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // Center Crosshair/Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on,
                color: AppTheme.black,
                size: 40,
              ),
            ),
          ),
          // Confirm Button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () => context.pop(_currentPosition),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
