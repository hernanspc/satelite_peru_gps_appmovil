// To parse this JSON data, do
//
//     final autosResponse = autosResponseFromJson(jsonString);

import 'dart:convert';

import 'package:satelite_peru_gps/domains/models/autos_models/Auto.dart';

AutosResponse autosResponseFromJson(String str) =>
    AutosResponse.fromJson(json.decode(str));

String autosResponseToJson(AutosResponse data) => json.encode(data.toJson());

class AutosResponse {
  bool? success;
  String? message;
  List<Auto>? autos;

  AutosResponse({
    this.success,
    this.message,
    this.autos,
  });

  AutosResponse copyWith({
    bool? success,
    String? message,
    List<Auto>? autos,
  }) =>
      AutosResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        autos: autos ?? this.autos,
      );

  factory AutosResponse.fromJson(Map<String, dynamic> json) => AutosResponse(
        success: json["success"],
        message: json["message"],
        autos: List<Auto>.from(json["autos"].map((x) => Auto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "autos": List<dynamic>.from(autos!.map((x) => x.toJson())),
      };
}
