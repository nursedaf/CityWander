import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/provider_data.dart';

class LocationService {
  Future<String?> getCurrentCityName(value, ProviderData? providerData) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://us1.locationiq.com/v1/reverse?key=LOCATIONAPIKEY&lat=${value.latitude}&lon=${value.longitude}&format=json'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      var jsonArray = jsonDecode(data);
      debugPrint(jsonArray.toString());
      final String? cityName = jsonArray["address"]["province"];
      print('Current city name: $cityName');
      providerData?.placeName = cityName ?? "";
      return cityName;
    } else {
      print(response.reasonPhrase);
    }
    return null;
  }
}
