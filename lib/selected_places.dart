import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citywander/service/local_db.dart';

import 'main.dart';

class SelectedPlaces extends StatefulWidget {
  const SelectedPlaces({super.key});

  @override
  _SelectedPlaces createState() => _SelectedPlaces();
}

class _SelectedPlaces extends State<SelectedPlaces> {
  late Future<Map<String, dynamic>> _placeMapFuture;
  List<String> selectedPlaces = [];

  @override
  void initState() {
    super.initState();
    _placeMapFuture = LocaleDbManager.instance.getPlaceMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 9, 95, 12),
          title: const Text('Your Route'),
          actions: [
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  LocaleDbManager.instance.clearAllValues();
                }),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _placeMapFuture,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, dynamic>? placeMap = snapshot.data;
              if (placeMap == null || placeMap.isEmpty) {
                return const Text('You have not selected any places yet.');
              } else {
                return ListView.builder(
                  itemCount: placeMap.length,
                  itemBuilder: (BuildContext context, int index) {
                    String placeName = placeMap.keys.elementAt(index);
                    LatLng latLng = LatLng(
                      placeMap[placeName]['latitude'],
                      placeMap[placeName]['longitude'],
                    );
                    return ListTile(
                      title: Text(placeName),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            LocaleDbManager.instance
                                .deletePlaceFromMap(placeName);
                            LocaleDbManager.instance.deleteRoute(
                                LatLng(latLng.latitude, latLng.longitude));
                            setState(() {
                              placeMap.remove(placeMap.keys.elementAt(index));
                            });
                          }),
                    );
                  },
                );
              }
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green[500],
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyApp(),
                ));
          },
          label: const Text('Show on Map'),
        ));
  }
}
