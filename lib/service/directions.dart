import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'local_db.dart';

class Directions {
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
      String origin = '${latitudes.first},${longitudes.first}';
      String destination = '${latitudes.last},${longitudes.last}';
      //waypoints eklicemm
      String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks';

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
