import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleDirectionsAPI {
  static const String baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String apiKey = 'AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks';

  Future<List<String>> getRoute(List<LatLng>? latLngList) async {
    List<double> latitudes = [];
    List<double> longitudes = [];
    Map<PolylineId, Polyline> polylines = {};

    for (LatLng latLng in latLngList!) {
      latitudes.add(latLng.latitude);
      longitudes.add(latLng.longitude);
    }
    print('Latitudes: $latitudes');
    print('Longitudes: $longitudes');

    if (latitudes.isEmpty && longitudes.isEmpty) {
      List<String> routeSteps = [];
      print("Rotaya hiçbir yer eklenmedi.");
      return routeSteps;
    } else {
      String origin = '${latitudes.first},${longitudes.first}';
      String destination = '${latitudes.last},${longitudes.last}';
      String waypoints = '';

      if (latitudes.length > 2 && longitudes.length > 2) {
        for (int i = 1; i < latitudes.length - 1; i++) {
          waypoints += '${latitudes[i]},${longitudes[i]}|';
        }
      }

      String requestUrl =
          '$baseUrl?origin=$origin&destination=$destination&waypoints=optimize:true|$waypoints&key=$apiKey';

      http.Response response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        List<String> routeSteps = [];
        if (responseData['status'] == 'OK') {
          List<dynamic> steps = responseData['routes'][0]['legs'][0]['steps'];
          for (var step in steps) {
            String instruction = step['html_instructions'];
            routeSteps.add(instruction);
          }
        } else {
          throw Exception('Error: ${responseData['status']}');
        }
        return routeSteps;
      } else {
        throw Exception('Failed to fetch route');
      }
    }
  }
}
