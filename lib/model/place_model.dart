class Place {
  final String name;
  final String info;
  final String lat;
  final String lng;
  final String category;
  final String? photo;
  Place({
    required this.name,
    required this.info,
    required this.lat,
    required this.lng,
    required this.category,
    required this.photo,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        name: json['place_name'],
        info: json['place_info'],
        lat: json['place_lat'],
        lng: json['place_lng'],
        category: json['place_category'],
        photo: json['photo']);
  }
}
