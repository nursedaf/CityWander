import 'dart:async';
import 'dart:collection';
import 'package:citywander/service/local_db.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'service/directions.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(37.7562, 29.0848),
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
    setState(() {
      var selectedPlaces = LocaleDbManager.instance.getLocations();
      for (int i = 0; i < selectedPlaces!.length; i++) {
        _markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: selectedPlaces![i],
          infoWindow: InfoWindow(
            title: 'Marker Title',
            snippet: 'Marker Snippet',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));

        _polyline.add(Polyline(
          polylineId: PolylineId('route'),
          points: latLen,
          color: Color.fromARGB(255, 0, 174, 255),
          width: 5,
        ));
      }
    });
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
