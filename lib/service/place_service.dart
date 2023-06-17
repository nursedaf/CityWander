import 'package:citywander/service/locationiq_serice.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:citywander/model/place_model.dart';

class PlaceService {
  Future<List<Place>> getPlace(String cityName) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://nursedaf.com/travel_api/'));
    request.body = json.encode({
      "name": "places_in_city",
      "param": {"city_name": cityName}
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      var jsonArray = jsonDecode(data);
      //debugPrint(jsonArray.toString());
      final List<Place> list = [];
      if (jsonArray["results"] != null) {
        for (var i = 0; i < jsonArray["results"].length; i++) {
          final entry = jsonArray["results"][i];
          list.add(Place.fromJson(entry));
        }
      }
      return list;
    } else {
      throw Exception("Failed");
    }
  }

  Future<bool> setPlace(Place place) async {
    var city = await LocationService().getCurrentCityName(
        LatLng(double.parse(place.lat), double.parse(place.lng)), null);
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://nursedaf.com/travel_api/'));
    request.body = json.encode({
      "name": "add_search_places",
      "param": {
        "place_name": place.name,
        "place_lat": double.parse(place.lat),
        "place_lng": double.parse(place.lng),
        "place_city": city
      }
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed");
    }
  }

  Future<bool> deletePlace(Place place) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://nursedaf.com/travel_api/'));
    request.body = json.encode({
      "name": "delete_search_place",
      "param": {"place_name": place.name}
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed");
    }
  }
}
