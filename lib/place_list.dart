import 'package:citywander/main.dart';
import 'package:flutter/material.dart';
import 'package:citywander/details_page.dart';
import 'package:citywander/providers/provider_data.dart';
import 'package:citywander/service/place_service.dart';
import 'package:citywander/model/place_model.dart';
import 'package:provider/provider.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({super.key});
  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  late Future<List<Place>> futurePlaces;

  ProviderData? providerData;

  @override
  void initState() {
    providerData = Provider.of(context, listen: false);

    super.initState();
    futurePlaces = PlaceService().getPlace(getCityName(providerData));
  }

  String getCityName(ProviderData? data) {
    return data?.placeName ?? "Mountain View";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getCityName(providerData)),
          backgroundColor: Colors.green[700],
        ),
        body: RefreshIndicator(
            color: Colors.green[700],
            child: Center(
              child: FutureBuilder<List<Place>>(
                future: futurePlaces,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.black26,
                      ),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        Place place = snapshot.data?[index];
                        return ListTile(
                          title: Text(place.name),
                          trailing: const Icon(Icons.chevron_right_outlined),
                          onTap: (() => {openPage(context, place)}),
                        );
                      },
                    );
                  } else {
                    return const Text('No places to visit found.');
                  }
                  //return const CircularProgressIndicator();
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
}
