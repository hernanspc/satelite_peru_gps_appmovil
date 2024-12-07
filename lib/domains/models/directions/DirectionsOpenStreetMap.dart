// To parse this JSON data, do
//
//     final directionsOpenStreetMap = directionsOpenStreetMapFromJson(jsonString);

import 'dart:convert';

DirectionsOpenStreetMap directionsOpenStreetMapFromJson(String str) =>
    DirectionsOpenStreetMap.fromJson(json.decode(str));

String directionsOpenStreetMapToJson(DirectionsOpenStreetMap data) =>
    json.encode(data.toJson());

class DirectionsOpenStreetMap {
  int placeId;
  String licence;
  String osmType;
  int osmId;
  String lat;
  String lon;
  String displayName;
  Address address;
  List<double> boundingbox;

  DirectionsOpenStreetMap({
    required this.placeId,
    required this.licence,
    required this.osmType,
    required this.osmId,
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.address,
    required this.boundingbox,
  });

  DirectionsOpenStreetMap copyWith({
    int? placeId,
    String? licence,
    String? osmType,
    int? osmId,
    String? lat,
    String? lon,
    String? displayName,
    Address? address,
    List<double>? boundingbox,
  }) =>
      DirectionsOpenStreetMap(
        placeId: placeId ?? this.placeId,
        licence: licence ?? this.licence,
        osmType: osmType ?? this.osmType,
        osmId: osmId ?? this.osmId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        displayName: displayName ?? this.displayName,
        address: address ?? this.address,
        boundingbox: boundingbox ?? this.boundingbox,
      );

  factory DirectionsOpenStreetMap.fromJson(Map<String, dynamic> json) =>
      DirectionsOpenStreetMap(
        placeId: json["place_id"],
        licence: json["licence"],
        osmType: json["osm_type"],
        osmId: json["osm_id"],
        lat: json["lat"],
        lon: json["lon"],
        displayName: json["display_name"],
        address: Address.fromJson(json["address"]),
        boundingbox:
            List<double>.from(json["boundingbox"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "licence": licence,
        "osm_type": osmType,
        "osm_id": osmId,
        "lat": lat,
        "lon": lon,
        "display_name": displayName,
        "address": address.toJson(),
        "boundingbox": List<dynamic>.from(boundingbox.map((x) => x)),
      };
}

class Address {
  String neighbourhood;
  String suburb;
  String city;
  String region;
  String state;
  int postcode;
  String country;
  String countryCode;

  Address({
    required this.neighbourhood,
    required this.suburb,
    required this.city,
    required this.region,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
  });

  Address copyWith({
    String? neighbourhood,
    String? suburb,
    String? city,
    String? region,
    String? state,
    int? postcode,
    String? country,
    String? countryCode,
  }) =>
      Address(
        neighbourhood: neighbourhood ?? this.neighbourhood,
        suburb: suburb ?? this.suburb,
        city: city ?? this.city,
        region: region ?? this.region,
        state: state ?? this.state,
        postcode: postcode ?? this.postcode,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        neighbourhood: json["neighbourhood"],
        suburb: json["suburb"],
        city: json["city"],
        region: json["region"],
        state: json["state"],
        postcode: json["postcode"],
        country: json["country"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "neighbourhood": neighbourhood,
        "suburb": suburb,
        "city": city,
        "region": region,
        "state": state,
        "postcode": postcode,
        "country": country,
        "country_code": countryCode,
      };
}
