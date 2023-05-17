class Cityname {
  final String name;

  const Cityname({
    required this.name,
  });

  factory Cityname.fromJson(Map<String, dynamic> json) {
    return Cityname(
      name: json['place_name'],
    );
  }
}
