import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_8/place_list.dart';
import 'package:maps_8/providers/provider_data.dart';
import 'package:maps_8/service/locationiq_serice.dart';
import 'package:maps_8/model/cityname_model.dart';
import 'package:provider/provider.dart';

void main() {
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
  final TextEditingController _searchController = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final List<LatLng> _polygonLatLngs = <LatLng>[];
  final int _polygonIdCounter = 1;

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
        markerId: MarkerId('marker'),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PlaceList()));
                    });
                  },
                  iconSize: 24,
                )
              ]),
          body: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: ' Seach by City'),
                    onChanged: (value) {
                      print(value);
                    },
                  )),
                ],
              ),
              Expanded(
                  child: GoogleMap(
                mapType: MapType.normal,
                markers: _markers,
                polygons: _polygons,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  location.getLocation().then((value) {
                    LocationService().getCurrentCityName(value, providerData);
                    _goToCurrentLocation(value.latitude, value.longitude);
                  });
                },
              )),
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
