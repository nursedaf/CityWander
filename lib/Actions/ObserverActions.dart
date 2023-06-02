import 'package:flutter/material.dart';
 class ObserverActions{
    static final ObserverActions _instance = ObserverActions._init();
    static ObserverActions get instance => _instance;
   ObserverActions._init();
     PlaceListUpdate get placeListChangeNotifier {
       _placeListUpdater ??= PlaceListUpdate();
       return _placeListUpdater;
     }
    var _placeListUpdater;
  }
   class PlaceListUpdate extends ChangeNotifier
   {
   }