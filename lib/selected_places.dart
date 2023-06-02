import 'package:citywander/route.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citywander/service/local_db.dart';

import 'place_list.dart';

class SelectedPlaces extends StatefulWidget {
  const SelectedPlaces({super.key});

  @override
  _SelectedPlaces createState() => _SelectedPlaces();
}

class _SelectedPlaces extends State<SelectedPlaces> {
  late Future<Map<String, dynamic>> _placeMapFuture;

  @override
  void initState() {
    super.initState();
    _placeMapFuture = fetchData();
  }

  void removeAllItems() {
    setState(() {
      _placeMapFuture = Future.value({});
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    _placeMapFuture = LocaleDbManager.instance.getPlaceMap();
    return _placeMapFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 9, 95, 12),
          title: const Text('Selected Places'),
          actions: [
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  LocaleDbManager.instance.clearAllValues();
                  removeAllItems();
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
                return Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No locations have been added yet. Select places.',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const PlaceList();
                            }));
                          },
                          style: ButtonStyle(
                            alignment: Alignment.centerLeft,
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 9, 95, 12),
                            ),
                          ),
                          child: const Text('Place List')),
                    ],
                  ),
                );
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
                  builder: (context) => const RoutePage(),
                ));
          },
          label: const Text('Show on Map'),
        ));
  }
}
