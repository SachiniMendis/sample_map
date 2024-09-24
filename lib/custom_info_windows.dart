import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomInfoWindows extends StatefulWidget {
  const CustomInfoWindows({super.key});

  @override
  State<CustomInfoWindows> createState() => _CustomInfoWindowsState();
}

class _CustomInfoWindowsState extends State<CustomInfoWindows> {
  // Controller to manage the custom info window's behavior
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  // Set of markers to be displayed on the map
  Set<Marker> markers = {};

  // List of coordinates (LatLng) where markers will be placed
  final List<LatLng> latlongPoint = [
    const LatLng(6.9271, 79.8475), //Shangri-La Hotel, Colombo
    const LatLng(7.8571, 80.6640), //Heritance Kandalama, Dambulla
    const LatLng(6.0497, 80.2110), //Jetwing Lighthouse, Galle
  ];

  // Corresponding names for the locations
  final List<String> locationNames = [
    " Shangri-La Hotel, Colombo",
    "  Heritance Kandalama, Dambulla",
    "  Jetwing Lighthouse, Galle",
  ];

  // Corresponding image URLs for the locations
  final List<String> locationImages = [
    "https://www.fivestaralliance.com/files/fivestaralliance.com/field/image/nodes/2018/46282/0_EXTERIOR-G.jpg",
    "https://th.bing.com/th/id/OIP.ZZhpBO0Wdxc2ZATIkrg1UwHaHa?rs=1&pid=ImgDetMain",
    "https://pix10.agoda.net/hotelImages/74903/-1/dba1f4cde0dedf8da1779297aa8ee4f7.jpg?s=1024x768",
  ];

  @override
  void initState() {
    super.initState();
    // Initialize and display the markers with custom info windows
    displayInfo();
  }

  // Function to add markers and custom info windows on the map
  displayInfo() {
    for (int i = 0; i < latlongPoint.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(i.toString()), // Unique identifier for each marker
          icon: BitmapDescriptor.defaultMarker, // Default marker icon
          position: latlongPoint[i], // Position of the marker
          onTap: () {
            // When marker is tapped, show the custom info window
            _customInfoWindowController.addInfoWindow!(
              Container(
                color: Colors.white, // Background color of the info window
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the corresponding image for the location
                    Image.network(
                      locationImages[i],
                      height: 125,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                    // const SizedBox(height: 4), // Spacer between image and text
                    // Display the corresponding name for the location

                    Text(
                      locationNames[i],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Text("(5)")
                      ],
                    )
                  ],
                ),
              ),
              latlongPoint[
                  i], // Position where the info window should be displayed
            );
          },
        ),
      );
      setState(() {}); // Update the UI to reflect the added markers
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('attractions in Sri Lanka'),leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
      ), 
      ),
      body: Stack(
        children: [
          // GoogleMap widget to display the map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(
                  6.9271, 79.8475), // Initial position of the camera (Pokhara)
              zoom: 7, // Initial zoom level
            ),
            markers: markers, // Set of markers to be displayed on the map
            onTap: (argument) {
              // Hide the custom info window when the map is tapped
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              // Update the position of the custom info window when the camera moves
              _customInfoWindowController.onCameraMove!();
            },
            onMapCreated: (GoogleMapController controller) {
             
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: 171, 
            width: 250,
            offset: 35, 
          ),
        ],
      ),
    );
  }
}
