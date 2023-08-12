import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getPlacePredictions(String input) async {
  String apiKey = 'GOOGLEAPIKEY';
  String url =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body);
    List<String> predictions = [];
    if (jsonResult['predictions'] != null) {
      for (var prediction in jsonResult['predictions']) {
        predictions.add(prediction['description']);
      }
    }
    return predictions;
  } else {
    throw Exception('Failed to fetch place predictions');
  }
}
