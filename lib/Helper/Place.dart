

class Place {
  String name, long, lat;

  Place({this.name, this.long, this.lat});

  factory Place.fromJson(dynamic json) {
    return new Place(
      name: json["display_name"],
      long: json["lon"],
      lat: json["lat"],
    );
  }  

  String toString() => "Name: $name, Latitude: $lat, Longitude: $long";

}