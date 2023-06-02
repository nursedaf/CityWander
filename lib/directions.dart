import 'dart:async';

import 'package:citywander/service/directions.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  PolylinePoints polylinePoints = PolylinePoints();
  final Set<Marker> _markers = {};
  //late Future<List<LatLng>> _route;
  late List<dynamic> _route;
  List<LatLng> _points = [];
  @override
  Future<void> initState() async {
    super.initState();
    //_route = LocaleDbManager.instance.getLocations() ?? [];
    _points = await Directions.getDirections(); //Future<List<LatLng>>
    
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker'),
        position: point,
      ));
    });
  }

  /*Future<List<LatLng>?> _fetchDirections() async {
    LatLng origin =
        LatLng(37.7749, -122.4194); // Replace with your origin coordinates
    LatLng destination =
        LatLng(34.0522, -118.2437); // Replace with your destination coordinates

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks',
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> route = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _route = route;
      });
    }
  }*/

  Location location = Location();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          //_goToCurrentLocation(_route[0].latitude, _route[0].longitude);
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(39.920611,
              32.853762), // Replace with your initial camera position
          zoom: 12,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            points: _points,
            width: 5,
          ),
        },
      ),
    );
  }

  Future<void> _goToCurrentLocation(double? latitude, double? longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15)));
  }
}
