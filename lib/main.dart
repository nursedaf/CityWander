import 'dart:async';
import 'dart:math';
import 'package:citywander/service/directions.dart';
import 'package:citywander/service/local_db.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:citywander/place_list.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:provider/provider.dart';
import 'Actions/ObserverActions.dart';
import 'model/place_model.dart';
import 'search.dart';

var _waitMapComplete = false;
var random = Random();
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
  Set<Polyline> _polyline = {};
  late List<LatLng> latLen = [];
  late Future<List<Place>> futurePlaces;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(39.9334, 32.8597),
    zoom: 14.4746,
  );
  @override
  void initState() {
    super.initState();
    future();
    ObserverActions.instance.placeListChangeNotifier
        .removeListener(placeListChanged);
    ObserverActions.instance.placeListChangeNotifier
        .addListener(placeListChanged);
  }

  Future<void> future() async {
    _waitMapComplete = true;
    try {
      var futureCoordinates = await Directions.getDirections();
      for (var coordinate in futureCoordinates) {
        latLen.add(coordinate);
      }
      await setMarkersFromSelectedPlaces();
      setPolyline();
    } catch (e) {
      print("Future Problem");
    }
    _waitMapComplete = false;
  }

  void setPolyline() {
    var selectedPlaces = LocaleDbManager.instance.getLocations();
    for (int i = 0; i < selectedPlaces!.length; i++) {
      String id = i.toString();
      _polyline.add(Polyline(
        polylineId: PolylineId('route' + random.nextInt(100).toString()),
        points: latLen,
        color: const Color.fromARGB(255, 54, 18, 186),
        width: 5,
      ));
    }
    setState(() {});
  }

  Future<void> setMarkersFromSelectedPlaces() async {
    Future<Map<String, dynamic>> selectedPlaces =
        LocaleDbManager.instance.getPlaceMap();
    var placeMap = await selectedPlaces;
    placeMap.forEach((placeName, placeData) {
      final latitude = placeData['latitude'];
      final longitude = placeData['longitude'];
      _markers.add(Marker(
        markerId: MarkerId(placeName + random.nextInt(100).toString()),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: placeName),
      ));
    });
    setState(() {});
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
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSearchPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
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
                        setMarkersFromSelectedPlaces();
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 5),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                              scale: 0.8,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(100)),
                                child: IconButton(
                                  onPressed: placeListButtonOnClicked,
                                  icon: const Icon(Icons.list),
                                  color: Colors.white,
                                ),
                              )),
                          Transform.scale(
                              scale: 0.8,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(100)),
                                child: IconButton(
                                    onPressed: CircleButtonOnClicked,
                                    icon: const Icon(Icons.circle),
                                    color: Colors.white),
                              )),
                        ])),
              ),
            ],
          ),
        ));
  }

  void placeListButtonOnClicked() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const PlaceList();
    }));
  }

  void CircleButtonOnClicked() {
    if (_waitMapComplete) return;
    latLen.clear();
    _markers.clear();
    _polyline.clear();
    future();
  }

  Future<void> _goToCurrentLocation(double? latitude, double? longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude!, longitude!), zoom: 15)));
    //_setMarker(LatLng(latitude, longitude));
  }

  void placeListChanged() {
    updateMap();
  }

  updateMap() async {
    await Future.delayed(Duration(milliseconds: 50));
    CircleButtonOnClicked();
  }
}
