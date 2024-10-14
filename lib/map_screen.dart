import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vinove_demo/members_screen.dart';
import 'package:vinove_demo/menu_screen.dart';
import 'package:vinove_demo/models/location_history.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  static const LatLng _uttrakhand = LatLng(30.0668, 79.0193);
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // to get the user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    updateLocationOnUI(position);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 15));

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 100),
    ).listen(
      (Position position) {
        updateLocationOnUI(position);
      },
    );
  }

  updateLocationOnUI(Position position) async {
    _currentPosition = LatLng(position.latitude, position.longitude);
  }

  Widget getMapForAllUser() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("usersLastLocations")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _markers.clear();
          QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
          data?.docs.forEach(
            (element) {
              LocationHistory locationHistory =
                  LocationHistory.fromJson(element.data());
              _markers.add(
                Marker(
                  markerId: MarkerId(locationHistory.place),
                  position: LatLng(locationHistory.lat.toDouble(),
                      locationHistory.long.toDouble()),
                  infoWindow: InfoWindow(title: locationHistory.place),
                ),
              );
            },
          );
        }

        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: const CameraPosition(
            target: _uttrakhand,
            zoom: 14,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          myLocationEnabled: true, // Shows the user's location on the map
        );
      },
    );
  }

  Future<Placemark> updateLocationInDb(Position position) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    List<Placemark> list =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String address =
        "${list.first.name} ${list.first.locality} ${list.first.postalCode} ${list.first.country}";
    LocationHistory locationHistory = LocationHistory(
      date: DateTime.now(),
      lat: position.latitude,
      long: position.longitude,
      place: address,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('locationHistory')
        .doc()
        .set(locationHistory.toJson());

    await FirebaseFirestore.instance
        .collection("usersLastLocations")
        .doc(uid)
        .set(locationHistory.toJson());

    return list.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATTENDANCE'),
        titleSpacing: -8,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MenuScreen()));
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Container(
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xffC9C5FF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.only(left: 1),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xffC9C5FF)),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MembersScreen()));
                        },
                        icon: const Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "All Members",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 115,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Change",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: getMapForAllUser(),
          ),
        ],
      ),
    );
  }
}
