import 'dart:convert'; // For JSON decoding

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps package
import 'package:http/http.dart' as http; // HTTP client package

class DirectionsPage extends StatefulWidget {
  @override
  _DirectionsPageState createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
  late GoogleMapController _mapController; // Controller for Google Map
  final LatLng _initialPosition =
      const LatLng(6.9271, 79.8612); // Initial map position (San Francisco)
  final TextEditingController _startController =
      TextEditingController(); // Controller for start location input
  final TextEditingController _endController =
      TextEditingController(); // Controller for end location input
  final Set<Marker> _markers = {}; // Set to store markers for map
  final Set<Polyline> _polylines = {}; // Set to store polylines for routes
  String _apiKey =
      'AIzaSyBvdWTRDRIKWd11ClIGYQrSfc883IEkRiw'; // Replace with your actual Google Maps API key

  @override
  void dispose() {
    // Dispose controllers when not needed
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // Function to handle map creation
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Function to fetch directions between two locations from Google Directions API
  Future<void> _getDirections(String start, String end) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=$_apiKey';

    final response = await http.get(Uri.parse(url)); // Make an HTTP request
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decode the JSON response

      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0]['overview_polyline']
            ['points']; // Get the encoded polyline
        _setMarkersAndRoute(
            start, end, route); // Set markers and route on the map
      } else {
        print('No route found.');
      }
    } else {
      print('Failed to fetch directions.');
    }
  }

  // Function to set markers and route on the map
  void _setMarkersAndRoute(String start, String end, String encodedRoute) {
    setState(() {
      _markers.clear(); // Clear any existing markers
      _polylines.clear(); // Clear any existing polylines

      // Add start marker
      _markers.add(Marker(
        markerId: MarkerId('start'),
        position: _getLatLngFromAddress(start),
        infoWindow: InfoWindow(title: 'Start'),
      ));

      // Add end marker
      _markers.add(Marker(
        markerId: MarkerId('end'),
        position: _getLatLngFromAddress(end),
        infoWindow: InfoWindow(title: 'End'),
      ));

      // Add polyline for the route
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: _decodePolyline(encodedRoute),
        color: const Color.fromARGB(255, 243, 33, 33),
        width: 5,
      ));
    });
  }

  // Function to get LatLng from an address (simplified for example)
  LatLng _getLatLngFromAddress(String address) {
    // For simplicity, using static locations; replace with dynamic location fetching if needed
    if (address.toLowerCase().contains('colombo')) {
      return LatLng(6.9271, 79.8612); // San Francisco coordinates
    } else if (address.toLowerCase().contains('colombo')) {
      return LatLng(6.9271, 79.8612); // Los Angeles coordinates
    } else {
      return _initialPosition; // Default position
    }
  }

  // Function to decode polyline from Google Directions API into a list of LatLng points
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(
          LatLng(lat / 1E5, lng / 1E5)); // Convert to LatLng and add to list
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Directions'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10.0,
            ),
            markers: _markers, // Markers for start and end points
            polylines: _polylines, // Polyline for route
          ),
          Column(
            children: [
              // Input field for start location
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter start location',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _startController.clear(),
                    ),
                  ),
                ),
              ),
              // Input field for end location
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter destination',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _endController.clear(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Button to get directions
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: ElevatedButton.icon(
              onPressed: () {
                _getDirections(_startController.text, _endController.text);
              },
              icon: Icon(Icons.directions),
              label: Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text and icon color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
