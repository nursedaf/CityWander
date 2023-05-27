import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> completer = Completer();
  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    if (!completer.isCompleted) {
      completer.complete(controller);
    }
  }

  addMarker(latLng, newSetState) {
    markers.add(Marker(
        consumeTapEvents: true,
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        onTap: () {
          markers.removeWhere(
              (element) => element.markerId == MarkerId(latLng.toString()));
          if (markers.length > 1) {
            getDirections(markers, newSetState);
          } else {
            polylines.clear();
          }
          newSetState(() {});
        }));
    if (markers.length > 1) {
      getDirections(markers, newSetState);
    }

    newSetState(() {});
  }

  getDirections(List<Marker> markers, newSetState) async {
    List<LatLng> polylineCoordinates = [];
    List<PolylineWayPoint> polylineWayPoints = [];
    for (var i = 0; i < markers.length; i++) {
      polylineWayPoints.add(PolylineWayPoint(
          location:
              "${markers[i].position.latitude.toString()},${markers[i].position.longitude.toString()}",
          stopOver: true));
    }
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks', //GoogleMap ApiKey
      PointLatLng(markers.first.position.latitude,
          markers.first.position.longitude), //first added marker
      PointLatLng(markers.last.position.latitude,
          markers.last.position.longitude), //last added marker
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    newSetState(() {});

    addPolyLine(polylineCoordinates, newSetState);
  }

  addPolyLine(List<LatLng> polylineCoordinates, newSetState) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;

    newSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          child: Container(
            height: 40,
            width: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: Text("Create Route", textAlign: TextAlign.center),
          ),
          onTap: () async {
            await showDialog(
                context: context,
                builder: (context) =>
                    StatefulBuilder(builder: (context, newSetState) {
                      return AlertDialog(
                        insetPadding: EdgeInsets.all(10),
                        contentPadding: EdgeInsets.all(5),
                        content: Stack(
                          children: [
                            Container(
                              width: 400,
                              height: 500,
                              child: GoogleMap(
                                mapToolbarEnabled: false,
                                onMapCreated: onMapCreated,
                                polylines: Set<Polyline>.of(polylines.values),
                                initialCameraPosition: const CameraPosition(
                                    target: LatLng(38.437532, 27.149606),
                                    zoom: 10),
                                markers: markers.toSet(),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                onTap: (newLatLng) async {
                                  await addMarker(newLatLng, newSetState);
                                  newSetState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                setState(() {});
                              },
                              child: Text('Approve Route'),
                            ),
                          ),
                        ],
                      );
                    }));
          },
        ),
      ),
    );
  }
}
