import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:maps_8/model/place_model.dart';

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
      debugPrint(jsonArray.toString());
      final List<Place> list = [];
      for (var i = 0; i < jsonArray["results"].length; i++) {
        final entry = jsonArray["results"][i];
        list.add(Place.fromJson(entry));
      }
      return list;
    } else {
      throw Exception("Failed");
    }
  }
}
