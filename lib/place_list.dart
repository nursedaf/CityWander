import 'dart:async';
import 'dart:developer';
import 'package:citywander/Actions/ObserverActions.dart';
import 'package:citywander/service/local_db.dart';
import 'package:citywander/service/locationiq_serice.dart';
import 'package:flutter/material.dart';
import 'package:citywander/details_page.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/service/place_service.dart';
import 'package:citywander/model/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({super.key});
  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  Future<List<Place>>? basePlace;
  Map<String, dynamic>? selectedPlaces;
  Map<String, dynamic>? searchedPlaces;

  ProviderData? providerData;
  String? title;
  var _loadingData = true;
  @override
  void initState() {
    super.initState();
    providerData = Provider.of(context, listen: false);
    ObserverActions.instance.placeListChangeNotifier
        .removeListener(placeListChangeCallback);
    ObserverActions.instance.placeListChangeNotifier
        .addListener(placeListChangeCallback);
    update();
  }

  Future<void> update() async {
    _loadingData = true;
    var location = await Location().getLocation();
    var cityName =
        await LocationService().getCurrentCityName(location, providerData!);
    selectedPlaces = await LocaleDbManager.instance.getPlaceMap();
    searchedPlaces = await LocaleDbManager.instance.getSearchedPlaces();
    setState(() {
      title = "Places in $cityName";
      basePlace = convertToPlaces(cityName!, searchedPlaces!);
    });
    _loadingData = false;
  }

  String getCityName(ProviderData? data) {
    return data?.placeName ?? "Mountain View";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title ?? "Loading..."),
          backgroundColor: Colors.green[700],
          actions: [
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  LocaleDbManager.instance.clearAllValues();
                  update();
                  const snackBar = SnackBar(
                    content: Text('All places and route deleted!'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }),
          ],
        ),
        body: RefreshIndicator(
            color: Colors.green[700],
            child: Center(
              child: FutureBuilder<List<Place>>(
                future: basePlace,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    _loadingData = false;
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.black26,
                      ),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        Place place = snapshot.data?[index];
                        var selectedContains =
                            selectedPlaces!.containsKey(place.name);
                        var searchedContains =
                            searchedPlaces!.containsKey(place.name);
                        return ListTile(
                            onTap: () => {listTileOnTap(context, place)},
                            title: Text(place.name),
                            trailing: selectedContains || searchedContains
                                ? IconButton(
                                    onPressed: () {
                                      placeDeleteButtonOnPressed(place);
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'Selected place has been deleted!'),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red))
                                : !searchedContains
                                    ? const Icon(Icons.chevron_right_outlined)
                                    : null);
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                    // return const Text('No places to visit found.');
                  }
                },
              ),
            ),
            onRefresh: () async {
              var placesBase =
                  await PlaceService().getPlace(getCityName(providerData));
              setState(() {
                basePlace = Future.value(placesBase);
              });
            }));
  }

  placeDeleteButtonOnPressed(Place place) {
    if (_loadingData) return;
    log("PlaceDeleted!", level: 2);
    placeDeleter(place);
  }

  placeDeleter(Place place) async {
    await LocaleDbManager.instance.deletePlaceFromMap(place.name);
    await LocaleDbManager.instance
        .deleteRoute(LatLng(double.parse(place.lat), double.parse(place.lng)));
    if (place.category == "9") {
      await LocaleDbManager.instance.deleteFromSearch(place.name);
    }
  }

  void placeListChangeCallback() {
    update();
  }

  listTileOnTap(BuildContext context, Place place) {
    if (_loadingData) return;
    openPage(context, place);
  }

  static openPage(context, Place place) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsPage(
                  place: place,
                  itemIndex: null,
                )));
  }

  Future<List<Place>> convertToPlaces(
      String cityName, Map<String, dynamic> searchedPlaces) async {
    List<Place> places = [];
    Future<List<Place>> basePlaceItems = PlaceService().getPlace(cityName);
    List<Place> basePlaces = await basePlaceItems;
    places.addAll(basePlaces);

    searchedPlaces.forEach((key, value) {
      String name = value['name'];
      String info = value['info'];
      String lat = value['lat'];
      String lng = value['lng'];
      String category = value['category'];
      String photo = value['photo'];

      Place place = Place(
        name: name,
        info: info,
        lat: lat,
        lng: lng,
        category: category,
        photo: photo,
      );
      places.add(place);
    });
    return places;
  }
}
