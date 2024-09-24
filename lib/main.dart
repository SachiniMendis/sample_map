import 'dart:convert'; // For JSON decoding

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps
import 'package:http/http.dart' as http; // HTTP client package

import 'custom_info_windows.dart'; // Import the custom info windows page
//import 'attractions_page.dart'; // Import the attractions page
import 'directions_page.dart'; // Import the directions page

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(7.8731, 80.7718); // Center on Sri Lanka
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  String _apiKey =
      'AIzaSyBvdWTRDRIKWd11ClIGYQrSfc883IEkRiw'; // Replace with your actual Google Maps API key

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Function to search for a city and move the map
  Future<void> _searchCity(String cityName) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$cityName&inputtype=textquery&fields=geometry&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['candidates'].isNotEmpty) {
        final location = data['candidates'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 12),
        );

        setState(() {
          _markers.clear(); // Clear any existing markers
          _markers.add(Marker(
            markerId: MarkerId(cityName),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: cityName),
          ));
        });
      } else {
        print('City not found.');
      }
    } else {
      throw Exception('Failed to fetch city location');
    }
  }

  // Function to get suggestions from the Places API
  Future<void> _getSuggestions(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> suggestions = data['predictions'];
      setState(() {
        _suggestions =
            suggestions.map((item) => item['description'].toString()).toList();
      });
    } else {
      print('Failed to fetch suggestions');
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 7.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _getSuggestions(value); // Fetch suggestions
                      } else {
                        setState(() {
                          _suggestions = [];
                        });
                      }
                    },
                    onSubmitted: (value) {
                      _searchCity(value); // Search for the entered city
                    },
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () {
                        _searchController.text = _suggestions[index];
                        _searchCity(_suggestions[
                            index]); // Search for the selected city
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Positioned widget to place the icons at the bottom right
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DirectionsPage()),
                    );
                  },
                  child: Icon(Icons.directions),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 10.0), // Space between buttons
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomInfoWindows()),
                    );
                  },
                  label: Text('Attractions'),
                  icon: Icon(Icons.attractions),
                  backgroundColor: const Color.fromARGB(255, 34, 216, 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
