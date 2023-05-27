import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'service/directions.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(37.96602796331482, 29.102725876321294),
    zoom: 15,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  late List<LatLng> latLen = [];
  @override
  void initState() {
    super.initState();
    future();
  }

  Future<void> future() async {
    var futureCoordinates = await Directions.getDirections();
    for (var coordinate in futureCoordinates) {
      latLen.add(coordinate);
      print(latLen);
    }
    setmarker();
  }

  void setmarker() {
    for (int i = 0; i < latLen.length; i++) {
      _markers.add(
          // added markers
          Marker(
        markerId: const MarkerId('marker'),
        position: latLen[i],
        /*infoWindow: InfoWindow(
          title: 'HOTEL',
          snippet: '5 Star Hotel',
        ),*/
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {});
      _polyline.add(Polyline(
        polylineId: PolylineId('route'),
        points: latLen,
        color: Colors.green,
      ));
    }
    /*List<LatLng> latLen = [
    LatLng(19.0759837, 72.8776559),
    LatLng(28.679079, 77.069710),
    LatLng(26.850000, 80.949997),
    LatLng(24.879999, 74.629997),
    LatLng(16.166700, 74.833298),
    LatLng(12.971599, 77.594563),
  ];*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F9D58),
        // title of app
        title: Text("Route"),
      ),
      body: Container(
        child: SafeArea(
          child: GoogleMap(
            initialCameraPosition: _kGoogle,
            mapType: MapType.normal,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            polylines: _polyline,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
