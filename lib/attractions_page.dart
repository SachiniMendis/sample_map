import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps

class AttractionsPage extends StatefulWidget {
  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  late GoogleMapController mapController;
  BitmapDescriptor? _customIcon; // Declare a variable to hold the custom icon

  // Center the map on Sri Lanka
  final LatLng _center = const LatLng(7.8731, 80.7718); // Center on Sri Lanka

  // List of markers for popular hotels
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadCustomMarker(); // Load the custom marker icon
  }

  // Function to load custom marker icon from assets
  Future<void> _loadCustomMarker() async {
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
          size: Size(1,1)), // Specify the size of the icon
      'assets/shangri-la.jpg', // Path to the image asset
    );

    setState(() {
      _customIcon = customIcon;
      _setMarkers(); // Set markers with the custom icon
    });
  }

  // Function to initialize markers with the custom icon
  void _setMarkers() {
    _markers.addAll({
      Marker(
        markerId: MarkerId('Shangri-La Colombo'),
        position: LatLng(6.9297, 79.8438),
        icon: _customIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon
        infoWindow: InfoWindow(title: 'Shangri-La Colombo'),
      ),
      Marker(
        markerId: MarkerId('Galle Face Hotel, Colombo'),
        position: LatLng(6.9215, 79.8471),
        //icon: _customIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon
        infoWindow: InfoWindow(title: 'Galle Face Hotel, Colombo'),
      ),
      Marker(
        markerId: MarkerId('Cinnamon Grand Colombo'),
        position: LatLng(6.9181, 79.8470),
        //icon: _customIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon
        infoWindow: InfoWindow(title: 'Cinnamon Grand Colombo'),
      ),
      Marker(
        markerId: MarkerId('Jetwing Lighthouse, Galle'),
        position: LatLng(6.0481, 80.2053),
        //icon: _customIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon
        infoWindow: InfoWindow(title: 'Jetwing Lighthouse, Galle'),
      ),
      // Add more markers with the same custom icon
      Marker(
        markerId: MarkerId('Anantara Peace Haven Tangalle Resort'),
        position: LatLng(5.9890, 80.7557),
        //icon: _customIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon
        infoWindow: InfoWindow(title: 'Anantara Peace Haven Tangalle Resort'),
      ),
      // Add the remaining markers with the same custom icon
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attractions in Sri Lanka'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 7.0,
        ),
        markers: _markers,
      ),
    );
  }
}
