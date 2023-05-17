import 'package:flutter/foundation.dart';

class ProviderList extends ChangeNotifier {
  List<Map<String, dynamic>> placesList = [];
  final String _placeName = "";
  final double _latitude = 0.0;
  final double _longitude = 0.0;
  String get placeName => _placeName;
  double get latitude => _latitude;
  double get langitude => _longitude;

  void addPlace(String placeName, double latitude, double longitude) {
    Map<String, dynamic> place = {
      'name': placeName,
      'latitude': latitude,
      'longitude': longitude,
    };

    placesList.add(place);
    notifyListeners();
  }
}
