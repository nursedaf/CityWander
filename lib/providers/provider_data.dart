import 'package:flutter/foundation.dart';

class ProviderData extends ChangeNotifier {
  String _placeName = "";
  String get placeName => _placeName;

  set placeName(String value) {
    _placeName = value;
    notifyListeners();
  }
}
