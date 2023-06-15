import 'dart:convert';
import 'dart:developer';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Actions/ObserverActions.dart';

import '../Actions/ObserverActions.dart';
import '../model/place_model.dart';

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
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
  }

  List<LatLng>? getLocations() {
    List<String> routes = _preferences?.getStringList("locations") ?? [];
    return routes.map((e) => LatLng.fromJson(jsonDecode(e))!).toList();
  }

  Future<List<LatLng>> locations() async {
    await prefInit();
    List<String> routes = _preferences?.getStringList("locations") ?? [];
    return routes.map((e) => LatLng.fromJson(jsonDecode(e))!).toList();
  }

  Future<void> addRoutes(List<LatLng> values) async {
    await instance._preferences?.setStringList(
        "locations", values.map((e) => e.toJson().toString()).toList());
  }

  Future<void> addRoute(LatLng value) async {
    List<LatLng>? routes = getLocations();
    if (routes != null && !routes.contains(value)) {
      routes.add(value);
      await addRoutes(routes);
    }
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
  }

  Future<void> deleteRoute(LatLng value) async {
    List<LatLng>? routes = getLocations();
    if (routes != null && routes.contains(value)) {
      routes.remove(value);
      await addRoutes(routes);
    }
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
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
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
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
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
  }

  Future<void> deleteFromSearch(String placeName) async {
    String? placeMapString = _preferences?.getString('searchlist');
    Map<String, dynamic>? placeMap;
    try {
      placeMap = placeMapString != null ? jsonDecode(placeMapString) : {};
    } catch (e) {
      placeMap = {};
    }

    placeMap?.remove(placeName);
    await _preferences?.setString('searchlist', jsonEncode(placeMap));
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
  }

  void addSearchtoList(String placeName, LatLng latLng) {
    String? list = _preferences?.getString('searchlist');
    Map<String, dynamic>? seachedlist;
    try {
      seachedlist = list != null ? jsonDecode(list) : {};
    } catch (e) {
      seachedlist = {};
    }
    seachedlist![placeName] = {
      'name': placeName,
      'info': "",
      'lat': latLng.latitude.toString(),
      'lng': latLng.longitude.toString(),
      'category': "9",
      'photo': ""
    };
    _preferences?.setString('searchlist', jsonEncode(seachedlist));
    ObserverActions.instance.placeListChangeNotifier.notifyListeners();
    print('Place added to the seached list: $placeName');
  }

  Future<Map<String, dynamic>> getSearchedPlaces() async {
    String? placeMapString = _preferences?.getString('searchlist');
    Map<String, dynamic>? placeMap;
    try {
      placeMap = placeMapString != null ? jsonDecode(placeMapString) : {};
    } catch (e) {
      placeMap = {};
    }
    print("Searched list: $placeMap");
    return placeMap!;
  }
}

enum PreferenceKeys { places }
