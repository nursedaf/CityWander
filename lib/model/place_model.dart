class Place {
  final String name;
  final String info;
  final String lat;
  final String lng;
  Place({
    required this.name,
    required this.info,
    required this.lat,
    required this.lng,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['place_name'],
      info: json['place_info'],
      lat: json['place_lat'],
      lng: json['place_lng'],
    );
  }
}
