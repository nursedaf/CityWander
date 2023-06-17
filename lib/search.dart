import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'providers/provider_data.dart';
import 'service/locationiq_serice.dart';
import 'service/search_service.dart';

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});
  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '123';
  List<dynamic> _placesList = [];
  late LocationData location;

  String apiKey = 'AIzaSyDrKMpYg-2dDhcdXLG6Y4Cd31dvOIEa3Ks';
  var _lastPlace;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onChange();
    });
  }

  void onChange() {
    // ignore: unnecessary_null_comparison
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    EasyDebounce.debounce('textDebouncer', const Duration(milliseconds: 150),
        () => debounceCallback());
  }

  debounceCallback() async {
    if (_lastPlace != _controller.text) {
      _lastPlace = _controller.text;
      var result = await getSuggesion(_controller.text);
      setState(() {
        _placesList = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: const Text("Search Place in City"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: 'Search places with name.'),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: _placesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: (() async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _placesList[index]
                                                  ["structured_formatting"]
                                              ["main_text"],
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          select(
                                              _placesList[index]['place_id']);
                                          Navigator.of(context).pop();
                                          late SnackBar snackBar = SnackBar(
                                            content: Text(
                                                '${_placesList[index]["structured_formatting"]["main_text"]} is added to the route.'),
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        },
                                        child: const Text('Add to Route'),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                          title: Text(_placesList[index]['description']),
                        );
                      })),
            ],
          )),
    );
  }
}
