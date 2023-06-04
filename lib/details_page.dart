import 'dart:developer';
import 'package:citywander/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citywander/model/place_model.dart';
import 'package:citywander/service/local_db.dart';
import 'package:provider/provider.dart';

import 'Actions/ObserverActions.dart';

class DetailsPage extends StatefulWidget {
  final Place place;
  const DetailsPage({super.key, required this.place, required itemIndex});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<LatLng> routes = [];
  @override
  void initState() {
    super.initState();
    routes = LocaleDbManager.instance.getLocations() ?? [];
  }

  final notifier = ChangeNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 95, 12),
        title: Text(widget.place.name),
      ),
      body: Center(
          child: Column(children: [
        const SizedBox(
          height: 30,
        ),
        Text(widget.place.info)
      ])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 9, 95, 12),
        onPressed: () {
          selected(widget.place);
        },
        label: const Text('Add to Route'),
      ),
    );
  }

  void selected(Place place) {
    Place selectedPlace = Place(
      name: place.name,
      lat: place.lat,
      lng: place.lng,
      info: place.info,
    );
    LocaleDbManager.instance.addPlaceToMap(
        selectedPlace.name,
        LatLng(
            double.parse(selectedPlace.lat), double.parse(selectedPlace.lng)));
    LocaleDbManager.instance.addRoute(LatLng(
        double.parse(selectedPlace.lat), double.parse(selectedPlace.lng)));
  }

  void placeMapUpdate(BuildContext context) {}
}
