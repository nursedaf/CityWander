import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'local_db.dart';
import 'package:location/location.dart';

class Directions {
  static const String apiKey = 'GOOGLE_API_KEY';

  static Future<List<LatLng>> getDirections() async {
    List<LatLng>? latLngList = LocaleDbManager.instance.getLocations();
    List<double> latitudes = [];
    List<double> longitudes = [];
    for (LatLng latLng in latLngList!) {
      latitudes.add(latLng.latitude);
      longitudes.add(latLng.longitude);
    }
    if (latitudes.isEmpty && longitudes.isEmpty) {
      List<LatLng> routeSteps = [];
      print("Rotaya hiçbir yer eklenmedi.");
      return routeSteps;
    } else {
      var start = await Location().getLocation();
      latitudes.insert(0, start.latitude ?? 0);
      longitudes.insert(0, start.longitude ?? 0);
      String origin = '${latitudes.first},${longitudes.first}';
      String destination = '${latitudes.last},${longitudes.last}';
      String waypoints = '';

      if (latitudes.length > 2 && longitudes.length > 2) {
        for (int i = 1; i < latitudes.length - 1; i++) {
          waypoints += '${latitudes[i]},${longitudes[i]}|';
        }
      }

      String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=optimize:true|$waypoints&key=$apiKey';

      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var decodedJson = json.decode(response.body);
        List<LatLng> route = _decodePolylinePoints(
            decodedJson['routes'][0]['overview_polyline']['points']);
        //LocaleDbManager.instance.addRoutes(route);
        return route;
      } else {
        throw Exception('Failed to fetch directions');
      }
    }
  }

  static List<LatLng> _decodePolylinePoints(String encodedPoints) {
    List<PointLatLng> decodedPoints =
        PolylinePoints().decodePolyline(encodedPoints);
    List<LatLng> points = decodedPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    return points;
  }
}
