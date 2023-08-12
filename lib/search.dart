import 'dart:convert';

import 'package:citywander/place_list.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:citywander/service/place_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:easy_debounce/easy_debounce.dart';
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

  String apiKey = 'GOOGLEAPIKEY';
  var _lastPlace;
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
    EasyDebounce.debounce('textDebouncer', const Duration(milliseconds: 150),
        () => debounceCallback());
  }

  debounceCallback() async {
    if (_lastPlace != _controller.text) {
      _lastPlace = _controller.text;
      var result = await getSuggesion(_controller.text);
      setState(() {
        _placesList = result;
      });
    }
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

  Future<List<dynamic>> getSuggesion(String input) async {
    var currentLocation = await Location().getLocation();
    var currentCity =
        await LocationService().getCurrentCityName(currentLocation, null);
    var lat = currentLocation.latitude;
    var long = currentLocation.longitude;
    var request =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=$lat,$long&radius=500&key=AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks";
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var predictions = jsonDecode(response.body.toString())['predictions'];
      var places = [];
      for (var prediction in predictions) {
        var description = prediction['description'];
        var terms = prediction['terms'];
        for (var term in terms) {
          if (term['value'] == currentCity) {
            places.add(prediction);
            break;
          }
        }
      }
      return places;
    } else {
      throw Exception('Failed to fetch directions');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[700],
          elevation: 0,
          title: const Text('Search Place in')),
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
                                          Navigator.of(context).pop();
                                          late SnackBar snackBar = SnackBar(
                                            content: Text(
                                                '${_placesList[index]["structured_formatting"]["main_text"]} is added to the route.'),
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
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
      LocaleDbManager.instance.addSearchtoList(placeName, LatLng(lat, lng));
      print(LatLng(lat, lng));
    } else {
      print(response.reasonPhrase);
    }
  }
}
