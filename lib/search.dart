import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'model/place_model.dart';
import 'service/local_db.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});
  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '123';
  List<dynamic> _placesList = [];
  late LocationData location;
  String apiKey = 'AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    suggestions(_controller.text);
    /*if (_controller.text.length > 4) {
      try {
        location = await Location().getLocation();
        final double? latitude = location.latitude;
        final double? longitude = location.longitude;

        Future<List> predictions =
            getSuggesion(_controller.text, latitude!, longitude!);
        setState(() {
          predictions;
        });
      } catch (error) {
        print('Error getting location: $error');
      }
     
    }*/
  }

  Future<void> suggestions(String input) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  Future<List> getSuggesion(
      String input, double latitude, double longitude) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request =
        '$baseURL?input=$input&location=$latitude,$longitude&radius=5000&key=$apiKey&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      _placesList = jsonDecode(response.body.toString())['predictions'];
      return _placesList;
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[700],
          elevation: 0,
          title: const Text('Search Place')),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: 'Search places with name.'),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: (() async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _placesList[index]
                                                  ["structured_formatting"]
                                              ["main_text"],
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          select(
                                              _placesList[index]['place_id']);
                                        },
                                        child: const Text('Add to Route'),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                          title: Text(_placesList[index]['description']),
                        );
                      })),
            ],
          )),
    );
  }

  Future<void> select(String placesId) async {
    String request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placesId&key=$apiKey';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      double lat = jsonDecode(response.body.toString())['result']['geometry']
          ['location']['lat'];
      double lng = jsonDecode(response.body.toString())['result']['geometry']
          ['location']['lng'];
      String placeName = jsonDecode(response.body.toString())['result']['name'];
      LocaleDbManager.instance.addRoute(LatLng(lat, lng));
      LocaleDbManager.instance.addPlaceToMap(placeName, LatLng(lat, lng));
      LocaleDbManager.instance.addFromSearch(placeName, LatLng(lat, lng));
      print(LatLng(lat, lng));
    } else {
      print(response.reasonPhrase);
    }
  }
}
