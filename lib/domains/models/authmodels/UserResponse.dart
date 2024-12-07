// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

import 'package:satelite_peru_gps/domains/models/authmodels/Usuario.dart';

UserResponse userResponseFromJson(String str) =>
    UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  bool? success;
  String? token;
  String? message;
  Usuario? usuario;

  UserResponse({
    this.success,
    this.token,
    this.message,
    this.usuario,
  });

  UserResponse copyWith({
    bool? success,
    String? token,
    String? message,
    Usuario? usuario,
  }) =>
      UserResponse(
        success: success ?? this.success,
        token: token ?? this.token,
        message: message ?? this.message,
        usuario: usuario ?? this.usuario,
      );

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        success: json["success"],
        token: json["token"],
        message: json["message"],
        usuario: Usuario.fromJson(json["usuario"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "token": token,
        "message": message,
        "usuario": usuario?.toJson(),
      };
}
