import 'dart:convert';
import 'dart:developer';
import 'package:citywander/model/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleDbManager {
  static final LocaleDbManager _instance = LocaleDbManager._init();

  SharedPreferences? _preferences;
  static LocaleDbManager get instance => _instance;
  LocaleDbManager._init() {
    SharedPreferences.getInstance().then((value) {
      _preferences = value;
    });
  }

  static prefInit() async {
    instance._preferences ??= await SharedPreferences.getInstance();
    return;
  }

  Future<void> setStringValue(PreferenceKeys key, String value) async {
    await _preferences!.setString(key.name, value);
  }

  String getStringValue(PreferenceKeys key) =>
      _preferences?.getString(key.name) ?? "";

  Future<void> setBoolValue(PreferenceKeys key, bool value) async {
    await _preferences!.setBool(key.name, value);
  }

  bool getBoolValue(PreferenceKeys key, {bool defaultValue = false}) =>
      _preferences?.getBool(key.name) ?? defaultValue;

  Future<void> setDoubleValue(PreferenceKeys key, double value) async {
    await _preferences!.setDouble(key.name, value);
  }

  double getDoubleValue(PreferenceKeys key) =>
      _preferences?.getDouble(key.name) ?? 0.0;

  Future<void> clearValueByKey(PreferenceKeys key) async {
    await _preferences!.remove(key.name);
  }

  Future<void> clearAllValues() async {
    await _preferences!.clear();
  }

  List<LatLng>? getLocations() {
    List<String> routes =
        instance._preferences?.getStringList(PreferenceKeys.places.name) ?? [];
    return routes.map((e) => LatLng.fromJson(jsonDecode(e))!).toList();
  }

  Future<void> addRoutes(List<LatLng> values) async {
    await instance._preferences?.setStringList(PreferenceKeys.places.name,
        values.map((e) => e.toJson().toString()).toList());
  }

  Future<void> addRoute(LatLng value) async {
    List<LatLng>? routes = getLocations();
    if (routes != null && !routes.contains(value)) {
      routes.add(value);
      await addRoutes(routes);
    }
  }

  Future<void> deleteRoute(LatLng value) async {
    List<LatLng>? routes = getLocations();
    if (routes != null && routes.contains(value)) {
      routes.remove(value);
      await addRoutes(routes);
    }
  }

  void addPlaceToMap(String placeName, LatLng latLng) async {
    String? placeMapString = _preferences?.getString('placeMap');

    Map<String, dynamic>? placeMap;
    try {
      placeMap = placeMapString != null ? jsonDecode(placeMapString) : {};
    } catch (e) {
      placeMap = {};
    }
    placeMap![placeName] = {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude
    };

    await _preferences?.setString('placeMap', jsonEncode(placeMap));
    print('Place added to the map: $placeName');
    print(placeMap);
  }

  Future<Map<String, dynamic>> getPlaceMap() async {
    String? placeMapString = _preferences?.getString('placeMap');
    Map<String, dynamic>? placeMap;
    try {
      placeMap = placeMapString != null ? jsonDecode(placeMapString) : {};
    } catch (e) {
      placeMap = {};
    }

    print(placeMap);
    return placeMap!;
  }

  Future<void> deletePlaceFromMap(String placeName) async {
    String? placeMapString = _preferences?.getString('placeMap');
    Map<String, dynamic>? placeMap;
    try {
      placeMap = placeMapString != null ? jsonDecode(placeMapString) : {};
    } catch (e) {
      placeMap = {};
    }

    placeMap?.remove(placeName);
    await _preferences?.setString('placeMap', jsonEncode(placeMap));
  }
}

enum PreferenceKeys { places }
