class LocationDescription {
  final double latitude;
  final double longitude;

  /// Name of the location
  final String place;

  LocationDescription(this.latitude, this.longitude, this.place);

  LocationDescription.fromJson(Map<String, dynamic> json)
      : latitude = json["latitude"] as double,
        longitude = json["longitude"] as double,
        place = json["place"];

  Map<String, dynamic> toJson() =>
      {"latitude": latitude, "longitude": longitude, "place": place};
}
