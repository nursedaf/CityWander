import 'dart:async';
import 'dart:developer';
import 'package:citywander/maps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:citywander/place_list.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/route.dart';
import 'package:citywander/service/local_db.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:provider/provider.dart';
import 'package:citywander/service/direction_service.dart';
import 'selected_places.dart';
import 'package:citywander/directions.dart';
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
  final Set<Marker> _markers = <Marker>{};
  late List<LatLng> routeSteps = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(39.920611, 32.853762),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('marker'),
        position: point,
      ));
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
              title: const Text('Maps'),
              backgroundColor: Colors.green[700],
              actions: <Widget>[
                Container(
                  child: Text('Places'),
                  alignment: Alignment.center,
                ),
                IconButton(
                  icon: Icon(Icons.account_balance),
                  onPressed: () {
                    location.getLocation().then((value) {
                      LocationService().getCurrentCityName(value, providerData);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlaceList()));
                    });
                  },
                  iconSize: 24,
                )
              ]),
          body: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.navigation),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectedPlaces()));
                    },
                    iconSize: 24,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text('Selected Places'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () async {
                      log(LocaleDbManager.instance.getLocations().toString());
                      /*routeSteps = await GoogleDirectionsAPI()
                          .getRoute(LocaleDbManager.instance.getLocations());
                      navigateToRoutePage(routeSteps);*/
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutePage(),
                        ),
                      );
                    },
                    iconSize: 24,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text('Rotayı Gör'),
                  ),
                ],
              ),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: _markers,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    location.getLocation().then((value) {
                      LocationService().getCurrentCityName(value, providerData);
                      _goToCurrentLocation(value.latitude, value.longitude);
                    });
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.green[500],
              onPressed: () {
                location.getLocation().then((value) {
                  LocationService().getCurrentCityName(value, providerData);
                  _goToCurrentLocation(value.latitude, value.longitude);
                });
              },
              label: const Text('Current Location')),
        ));
  }

  Future<void> _goToCurrentLocation(double? latitude, double? longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15)));
    _setMarker(LatLng(latitude, longitude));
  }
}
