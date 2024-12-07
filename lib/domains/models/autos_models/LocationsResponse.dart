// To parse this JSON data, do
//
//     final locationsResponse = locationsResponseFromJson(jsonString);

import 'dart:convert';

LocationsResponse locationsResponseFromJson(String str) =>
    LocationsResponse.fromJson(json.decode(str));

String locationsResponseToJson(LocationsResponse data) =>
    json.encode(data.toJson());

class LocationsResponse {
  int? idVehiculo;
  int? imeil;
  String? placa;
  int? idFlota;
  int? cuentaId;
  DateTime? reporteFechaDesde;
  DateTime? reporteFechaHasta;
  List<Evento>? eventos;
  String? type;
  Flota? flota;

  LocationsResponse({
    this.idVehiculo,
    this.imeil,
    this.placa,
    this.idFlota,
    this.cuentaId,
    this.reporteFechaDesde,
    this.reporteFechaHasta,
    this.eventos,
    this.type,
    this.flota,
  });

  LocationsResponse copyWith({
    int? idVehiculo,
    int? imeil,
    String? placa,
    int? idFlota,
    int? cuentaId,
    DateTime? reporteFechaDesde,
    DateTime? reporteFechaHasta,
    List<Evento>? eventos,
    String? type,
    Flota? flota,
  }) =>
      LocationsResponse(
        idVehiculo: idVehiculo ?? this.idVehiculo,
        imeil: imeil ?? this.imeil,
        placa: placa ?? this.placa,
        idFlota: idFlota ?? this.idFlota,
        cuentaId: cuentaId ?? this.cuentaId,
        reporteFechaDesde: reporteFechaDesde ?? this.reporteFechaDesde,
        reporteFechaHasta: reporteFechaHasta ?? this.reporteFechaHasta,
        eventos: eventos ?? this.eventos,
        type: type ?? this.type,
        flota: flota ?? this.flota,
      );

  factory LocationsResponse.fromJson(Map<String, dynamic> json) =>
      LocationsResponse(
        idVehiculo: json["id_vehiculo"],
        imeil: json["imeil"],
        placa: json["placa"],
        idFlota: json["id_flota"],
        cuentaId: json["cuenta_id"],
        reporteFechaDesde: DateTime.parse(json["reporte_fecha_desde"]),
        reporteFechaHasta: DateTime.parse(json["reporte_fecha_hasta"]),
        eventos:
            List<Evento>.from(json["eventos"].map((x) => Evento.fromJson(x))),
        type: json["type"],
        flota: Flota.fromJson(json["flota"]),
      );

  Map<String, dynamic> toJson() => {
        "id_vehiculo": idVehiculo,
        "imeil": imeil,
        "placa": placa,
        "id_flota": idFlota,
        "cuenta_id": cuentaId,
        "reporte_fecha_desde": reporteFechaDesde?.toIso8601String(),
        "reporte_fecha_hasta": reporteFechaHasta?.toIso8601String(),
        "eventos": List<dynamic>.from(eventos!.map((x) => x.toJson())),
        "type": type,
        "flota": flota?.toJson(),
      };
}

class Evento {
  double? latitud;
  double? longitud;

  Evento({
    this.latitud,
    this.longitud,
  });

  Evento copyWith({
    double? latitud,
    double? longitud,
  }) =>
      Evento(
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
      );

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        latitud: json["latitud"].toDouble(),
        longitud: json["longitud"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitud": latitud,
        "longitud": longitud,
      };
}

class Flota {
  int id;
  int kmVuelta;

  Flota({
    required this.id,
    required this.kmVuelta,
  });

  Flota copyWith({
    int? id,
    int? kmVuelta,
  }) =>
      Flota(
        id: id ?? this.id,
        kmVuelta: kmVuelta ?? this.kmVuelta,
      );

  factory Flota.fromJson(Map<String, dynamic> json) => Flota(
        id: json["id"],
        kmVuelta: json["km_vuelta"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "km_vuelta": kmVuelta,
      };
}
