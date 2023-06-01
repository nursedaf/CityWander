import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:citywander/place_list.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/route.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:provider/provider.dart';
import 'model/place_model.dart';
import 'selected_places.dart';
import 'service/place_service.dart';

void main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ProviderData()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MapSample(),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  late List<LatLng> latLen = [];
  late Future<List<Place>> futurePlaces;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(39.9334, 32.8597),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
  }

  Location location = Location();
  Future<void> _loadMarkers(String? cityname) async {
    final places = await PlaceService().getPlace(cityname!);
    if (places.isNotEmpty) {
      final markers = places.map((place) {
        return Marker(
          markerId: MarkerId(place.name),
          position: LatLng(double.parse(place.lat), double.parse(place.lng)),
          infoWindow: InfoWindow(
            title: place.name,
            //snippet: place.info,
          ),
        );
      }).toSet();
      setState(() {
        _markers = markers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ProviderData providerData = context.watch();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('CityWander'),
            backgroundColor: Colors.green[700],
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.place),
                position: PopupMenuPosition.under,
                itemBuilder: (context1) {
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
                      child: Text("Your Route"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const PlaceList();
                    }));
                  } else if (value == 1) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const SelectedPlaces();
                    }));
                  } else if (value == 2) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const RoutePage();
                    }));
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    mapType: MapType.normal,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    zoomGesturesEnabled: true,
                    polylines: _polyline,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      location.getLocation().then((value) async {
                        String? cityname = await LocationService()
                            .getCurrentCityName(value, providerData);
                        _goToCurrentLocation(value.latitude, value.longitude);
                        _loadMarkers(cityname);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _goToCurrentLocation(double? latitude, double? longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15)));
    //_setMarker(LatLng(latitude, longitude));
  }
}
