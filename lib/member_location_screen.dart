import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vinove_demo/models/location_history.dart';
import 'package:vinove_demo/route_screen.dart';

class LocationScreen extends StatefulWidget {
  final String memberId;

  const LocationScreen({super.key, required this.memberId});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<LocationHistory> visitedLocations = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchVisitedLocations();
  }


  void _fetchVisitedLocations() async {
    QuerySnapshot<Map<String, dynamic>> data = await _firestore
        .collection('users')
        .doc(widget.memberId)
        .collection('locationHistory')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      for (var doc in data.docs) {
        visitedLocations.add(LocationHistory.fromJson(doc.data()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TRACK LIVE LOCATION")),
      body: Stack(
        children: [
          // Map section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: visitedLocations.isNotEmpty
                    ? LatLng(visitedLocations.first.lat.toDouble(),
                        visitedLocations.first.long.toDouble())
                    : const LatLng(30.0668, 79.0193),
                zoom: 14,
              ),
              markers: <Marker>{
                if (visitedLocations.isNotEmpty)
                  Marker(
                    markerId: MarkerId(visitedLocations.first.place),
                    position: LatLng(visitedLocations.first.lat.toDouble(),
                        visitedLocations.first.long.toDouble()),
                    infoWindow: InfoWindow(
                      title: visitedLocations.first.place,
                      snippet: visitedLocations.first.date.toIso8601String(),
                    ),
                  ),
              },
              onMapCreated: (GoogleMapController controller) {
                controller.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(visitedLocations.first.lat.toDouble(), visitedLocations.first.long.toDouble()), 15));
              }
            ),
          ),

          //ScrollableSheet for the list of sites
          DraggableScrollableSheet(
            initialChildSize: 0.3, // Size when collapsed
            minChildSize: 0.3, // Minimum size
            maxChildSize: 0.8, // Size when fully expanded

            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Total Sites and Date Selector
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Sites: ${visitedLocations.length}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(selectedDate,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(),

                    Expanded(
                      child: visitedLocations.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: visitedLocations.length,
                              itemBuilder: (context, index) {
                                LocationHistory location =
                                    visitedLocations[index];

                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const SizedBox(width: 4),
                                    Column(
                                      children: [
                                        const Icon(Icons.circle,
                                            size: 12,
                                            color: Color(0xff4434A7)),
                                        if (index !=
                                            visitedLocations.length - 1)
                                          Container(
                                            height: 45,
                                            width: 1,
                                            color: const Color(0xff4434A7),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 45,
                                      width:
                                          MediaQuery.of(context).size.width -
                                              28,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        visualDensity:
                                            const VisualDensity(vertical: -4),
                                        dense: true,
                                        title: Text(
                                          location.place,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle:
                                            Text('Left at ${location.date}'),
                                        trailing: IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RouteScreen(
                                                  memberId: widget.memberId,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.arrow_forward_ios),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

