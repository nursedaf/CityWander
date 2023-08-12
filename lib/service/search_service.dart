import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getPlacePredictions(String input) async {
  // Replace YOUR_API_KEY with your actual Google Places API key
  String apiKey = 'YOUR_API_KEY';
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
