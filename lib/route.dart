import 'dart:async';
import 'dart:collection';
import 'package:citywander/main.dart';
import 'package:citywander/service/local_db.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'model/place_model.dart';
import 'place_list.dart';
import 'providers/provider_data.dart';
import 'selected_places.dart';
import 'service/directions.dart';
import 'service/locationiq_serice.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(37.7562, 29.0848),
    zoom: 14.4746,
  );
  late Future<Set<Marker>> _markersFuture;
  late Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  late List<LatLng> latLen = [];
  final List<Place> list = [];
  @override
  void initState() {
    super.initState();
    future();
    _markersFuture = setMarkersFromSelectedPlaces();
  }

  Future<void> future() async {
    var futureCoordinates = await Directions.getDirections();
    for (var coordinate in futureCoordinates) {
      latLen.add(coordinate);
    }
    setPolyline();
  }

  Future<Set<Marker>> setMarkersFromSelectedPlaces() async {
    Future<Map<String, dynamic>> selectedPlaces =
        LocaleDbManager.instance.getPlaceMap();
    final placeMap = await selectedPlaces;

    placeMap.forEach((placeName, placeData) {
      final latitude = placeData['latitude'];
      final longitude = placeData['longitude'];
      _markers.add(Marker(
        markerId: MarkerId(placeName),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: placeName),
      ));
    });

    return _markers;
  }

  void setPolyline() {
    setState(() {
      var selectedPlaces = LocaleDbManager.instance.getLocations();
      for (int i = 0; i < selectedPlaces!.length; i++) {
        String id = i.toString();
        _polyline.add(Polyline(
          polylineId: PolylineId('route$id'),
          points: latLen,
          color: const Color.fromARGB(255, 54, 18, 186),
          width: 5,
        ));
      }
    });
  }

  Location location = Location();

  @override
  Widget build(BuildContext context) {
    ProviderData providerData = context.watch();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Your Route"),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.place),
            position: PopupMenuPosition.under,
            itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("City Places List"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("Selected Places"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("Home Page"),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                location.getLocation().then((value) {
                  LocationService().getCurrentCityName(value, providerData);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const PlaceList();
                  }));
                });
              } else if (value == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const SelectedPlaces();
                }));
              } else if (value == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyApp();
                }));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Set<Marker>>(
        future: _markersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final markers = snapshot.data ?? Set<Marker>();
            return GoogleMap(
              initialCameraPosition: _kGoogle,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              markers: markers,
              polylines: _polyline,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
          }
        },
      ),
    );
  }
}
