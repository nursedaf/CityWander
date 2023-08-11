import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'local_db.dart';
import 'locationiq_serice.dart';

String apiKey = 'GOOGLEAPIKEY';

Future<List<dynamic>> getSuggesion(String input) async {
  var currentLocation = await Location().getLocation();
  var currentCity =
      await LocationService().getCurrentCityName(currentLocation, null);
  var lat = currentLocation.latitude;
  var long = currentLocation.longitude;
  var request =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=$lat,$long&radius=500&key=$apiKey";
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
