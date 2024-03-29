import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citywander/model/place_model.dart';
import 'package:citywander/service/local_db.dart';

class DetailsPage extends StatefulWidget {
  final Place place;
  const DetailsPage({super.key, required this.place, required itemIndex});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<LatLng> routes = [];
  @override
  void initState() {
    super.initState();
    routes = LocaleDbManager.instance.getLocations() ?? [];
  }

  final notifier = ChangeNotifier();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 9, 95, 12),
        title: Text(widget.place.name),
      ),
      body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.place.photo != null)
          Image.network(
            widget.place.photo!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: Text('Loading...'));
            },
            errorBuilder: (context, error, stackTrace) => const Text(''),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.place.info,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        )
      ])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 9, 95, 12),
        onPressed: () {
          selected(widget.place);
          late SnackBar snackBar = SnackBar(
            content: Text('${widget.place.name} is added to the route.'),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        label: const Text('Add to Route'),
      ),
    );
  }

  void selected(Place place) {
    Place selectedPlace = Place(
        name: place.name,
        lat: place.lat,
        lng: place.lng,
        info: place.info,
        category: place.category,
        photo: place.photo);
    LocaleDbManager.instance.addPlaceToMap(
        selectedPlace.name,
        LatLng(
            double.parse(selectedPlace.lat), double.parse(selectedPlace.lng)));
    LocaleDbManager.instance.addRoute(LatLng(
        double.parse(selectedPlace.lat), double.parse(selectedPlace.lng)));
  }

  void placeMapUpdate(BuildContext context) {}
}
