// To parse this JSON data, do
//
//     final reportResponse = reportResponseFromJson(jsonString);

import 'dart:convert';

ReportResponse reportResponseFromJson(String str) =>
    ReportResponse.fromJson(json.decode(str));

String reportResponseToJson(ReportResponse data) => json.encode(data.toJson());

class ReportResponse {
  bool success;
  String message;
  Reporte reporte;

  ReportResponse({
    required this.success,
    required this.message,
    required this.reporte,
  });

  ReportResponse copyWith({
    bool? success,
    String? message,
    Reporte? reporte,
  }) =>
      ReportResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        reporte: reporte ?? this.reporte,
      );

  factory ReportResponse.fromJson(Map<String, dynamic> json) => ReportResponse(
        success: json["success"],
        message: json["message"],
        reporte: Reporte.fromJson(json["reporte"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "reporte": reporte.toJson(),
      };
}

class Reporte {
  int idVehiculo;
  int imeil;
  String placa;
  int idFlota;
  int cuentaId;
  DateTime reporteFechaDesde;
  DateTime reporteFechaHasta;
  dynamic reporteKilometraje;
  String type;
  Flota flota;

  Reporte({
    required this.idVehiculo,
    required this.imeil,
    required this.placa,
    required this.idFlota,
    required this.cuentaId,
    required this.reporteFechaDesde,
    required this.reporteFechaHasta,
    required this.reporteKilometraje,
    required this.type,
    required this.flota,
  });

  Reporte copyWith({
    int? idVehiculo,
    int? imeil,
    String? placa,
    int? idFlota,
    int? cuentaId,
    DateTime? reporteFechaDesde,
    DateTime? reporteFechaHasta,
    dynamic? reporteKilometraje,
    String? tipoBusqueda,
    Flota? flota,
  }) =>
      Reporte(
        idVehiculo: idVehiculo ?? this.idVehiculo,
        imeil: imeil ?? this.imeil,
        placa: placa ?? this.placa,
        idFlota: idFlota ?? this.idFlota,
        cuentaId: cuentaId ?? this.cuentaId,
        reporteFechaDesde: reporteFechaDesde ?? this.reporteFechaDesde,
        reporteFechaHasta: reporteFechaHasta ?? this.reporteFechaHasta,
        reporteKilometraje: reporteKilometraje ?? this.reporteKilometraje,
        type: type ?? this.type,
        flota: flota ?? this.flota,
      );

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
        idVehiculo: json["id_vehiculo"],
        imeil: json["imeil"],
        placa: json["placa"],
        idFlota: json["id_flota"],
        cuentaId: json["cuenta_id"],
        reporteFechaDesde: DateTime.parse(json["reporte_fecha_desde"]),
        reporteFechaHasta: DateTime.parse(json["reporte_fecha_hasta"]),
        reporteKilometraje: json["reporte_kilometraje"],
        type: json["type"],
        flota: Flota.fromJson(json["flota"]),
      );

  Map<String, dynamic> toJson() => {
        "id_vehiculo": idVehiculo,
        "imeil": imeil,
        "placa": placa,
        "id_flota": idFlota,
        "cuenta_id": cuentaId,
        "reporte_fecha_desde": reporteFechaDesde.toIso8601String(),
        "reporte_fecha_hasta": reporteFechaHasta.toIso8601String(),
        "reporte_kilometraje": reporteKilometraje,
        "type": type,
        "flota": flota.toJson(),
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
