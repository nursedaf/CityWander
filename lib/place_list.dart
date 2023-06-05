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
  Future<List<Place>>? futurePlaces;
  Map<String, dynamic>? selectedPlaces;

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
    //  futurePlaces = PlaceService().getPlace(getCityName(providerData));
    update();
  }

  Future<void> update() async {
    _loadingData = true;
    var location = await Location().getLocation();
    var cityName =
        await LocationService().getCurrentCityName(location, providerData!);
    selectedPlaces = await LocaleDbManager.instance.getPlaceMap();
    setState(() {
      title = cityName;
      futurePlaces = PlaceService().getPlace(cityName!);
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
                future: futurePlaces,
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

                        return ListTile(
                            onTap: () => listTileOnTap(context, place),
                            title: Text(place.name),
                            trailing: selectedContains
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
                                : const Icon(Icons.chevron_right_outlined));
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
              var places =
                  await PlaceService().getPlace(getCityName(providerData));
              setState(() {
                futurePlaces = Future.value(places);
              });
            }));
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

  placeDeleteButtonOnPressed(Place place) {
    if (_loadingData) return;
    log("PlaceDeleted!", level: 2);
    placeDeleter(place);
  }

  placeDeleter(Place place) async {
    await LocaleDbManager.instance.deletePlaceFromMap(place.name);
    await LocaleDbManager.instance
        .deleteRoute(LatLng(double.parse(place.lat), double.parse(place.lng)));
  }

  void placeListChangeCallback() {
    update();
  }

  listTileOnTap(BuildContext context, Place place) {
    if (_loadingData) return;
    openPage(context, place);
  }
}
