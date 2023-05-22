import 'package:flutter/material.dart';
import 'package:maps_8/model/place_model.dart';
import 'package:maps_8/providers/provider_data.dart';
import 'package:provider/provider.dart';
import 'package:maps_8/providers/provider_list.dart';

class DetailsPage extends StatefulWidget {
  final Place place;
  const DetailsPage({super.key, required this.place, required itemIndex});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  final RouteList routeList = RouteList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 9, 95, 12),
        title: Text('${widget.place.name}'),
      ),
      body: Center(
          child: Column(children: [
        const SizedBox(
          height: 30,
        ),
        Text(widget.place.info)
      ])),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromARGB(255, 9, 95, 12),
        onPressed: () {
        routeList.addPlace(widget.place);
        },
        label: const Text('Add to Route'),
      ),
    );
  }
}

class RouteList {
  Map<String, Place> PlaceMap = {};
  void addPlace(Place place) {
    PlaceMap[place.name] = place;
    print(PlaceMap[place.name]?.name);
  }

  Map<String, Place> GetPlaceMap() {
    return PlaceMap;
  }
}
