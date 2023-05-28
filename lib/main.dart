import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:citywander/place_list.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/route.dart';
import 'package:citywander/service/local_db.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:provider/provider.dart';
import 'selected_places.dart';
import 'service/directions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleDbManager.prefInit();
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
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  late List<LatLng> latLen = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(39.920611, 32.853762),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    future();
  }

  Future<void> future() async {
    var futureCoordinates = await Directions.getDirections();
    latLen.clear();
    for (var coordinate in futureCoordinates) {
      latLen.add(coordinate);
    }
    setmarker();
  }

  void setmarker() {
    setState(() {
      var selectedPlaces = LocaleDbManager.instance.getLocations();
      for (int i = 0; i < selectedPlaces!.length; i++) {
        _markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: selectedPlaces[i],
          infoWindow: InfoWindow(
            title: 'Marker Title',
            snippet: 'Marker Snippet',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
        _polyline.add(Polyline(
          polylineId: PolylineId('route'),
          points: latLen,
          color: Color.fromARGB(255, 54, 18, 186),
          width: 5,
        ));
      }
    });
  }

  Location location = Location();

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
                      child: Text("Your Route"),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    location.getLocation().then((value) {
                      LocationService().getCurrentCityName(value, providerData);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const PlaceList();
                      }));
                    });
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
              /*Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.navigation),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SelectedPlaces();
                      }));
                    },
                    iconSize: 24,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text('Selected Places'),
                  ),
                ],
              ),*/
              Expanded(
                child: Container(
                  child: SafeArea(
                    child: GoogleMap(
                      initialCameraPosition: _kGooglePlex,
                      mapType: MapType.normal,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      polylines: _polyline,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        location.getLocation().then((value) {
                          LocationService()
                              .getCurrentCityName(value, providerData);
                          _goToCurrentLocation(value.latitude, value.longitude);
                        });
                      },
                    ),
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
