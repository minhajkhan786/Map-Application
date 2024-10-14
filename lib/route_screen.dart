import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteScreen extends StatelessWidget {
  final String memberId;

  const RouteScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Details")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0668, 79.0193),
              zoom: 8,
            ),
            polylines: _createRoutePolyline(),
            markers: _createStopMarkers(),
          ),
          const Positioned(
            bottom: 50,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Start Location: ..."),
                    Text("Stop Location: ..."),
                    Text("Total Distance: ..."),
                    Text("Total Duration: ..."),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Polyline> _createRoutePolyline() {
    Set<Polyline> polylines = {
      const Polyline(
        polylineId: PolylineId("route1"),
        color: Color(0xff4434A7),
        width: 7,
        points: [
          LatLng(30.0668, 79.0193),
          LatLng( 29.854263, 77.888000),
        ],
      ),
    };
    return polylines;
  }

  Set<Marker> _createStopMarkers() {
    Set<Marker> stopMarkers = {
      const Marker(
        markerId: MarkerId("stop1"),
        position: LatLng(29.854263, 77.888000),
        infoWindow: InfoWindow(title: "Stop Location"),
      ),
    };
    return stopMarkers;
  }
}