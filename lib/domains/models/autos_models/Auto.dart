// To parse this JSON data, do
//
//     final autosResponse = autosResponseFromJson(jsonString);

import 'dart:convert';

class Auto {
  dynamic? idVehiculo;
  dynamic? placa;
  dynamic? codigoInterno;
  dynamic? acc;
  dynamic? velocidad;
  dynamic? terminal;
  dynamic? kilometrajeAcum;
  dynamic? latitud;
  dynamic? longitud;
  dynamic? fecha;
  dynamic? fechaEncendido;
  dynamic? fechapagado;
  dynamic? fechaTramaActual;
  dynamic? kilometrajeAcumuladoAyer;
  dynamic? kilometrajeAcumuladoMes;
  dynamic? direccionTramaActual;
  dynamic? nombreConductor;
  dynamic? imagenConductor;
  dynamic? imeil;
  dynamic? sim;
  dynamic? kmgalon;

  Auto(
      {required this.idVehiculo,
      required this.placa,
      required this.codigoInterno,
      required this.acc,
      required this.velocidad,
      required this.terminal,
      required this.kilometrajeAcum,
      required this.latitud,
      required this.longitud,
      required this.fecha,
      required this.fechaEncendido,
      required this.fechapagado,
      this.fechaTramaActual,
      required this.kilometrajeAcumuladoAyer,
      required this.kilometrajeAcumuladoMes,
      this.direccionTramaActual,
      this.nombreConductor,
      this.imagenConductor,
      this.imeil,
      this.sim,
      this.kmgalon});

  Auto copyWith({
    dynamic? idVehiculo,
    dynamic? placa,
    dynamic? codigoInterno,
    dynamic? acc,
    dynamic? velocidad,
    dynamic? terminal,
    dynamic? kilometrajeAcum,
    dynamic? latitud,
    dynamic? longitud,
    dynamic? fecha,
    dynamic? fechaEncendido,
    dynamic? fechapagado,
    dynamic? kilometrajeAcumuladoAyer,
    dynamic? kilometrajeAcumuladoMes,
    dynamic? direccionTramaActual,
    dynamic? nombreConductor,
    dynamic? imagenConductor,
    dynamic? imeil,
    dynamic? sim,
    dynamic? kmgalon,
  }) =>
      Auto(
        idVehiculo: idVehiculo ?? this.idVehiculo,
        placa: placa ?? this.placa,
        codigoInterno: codigoInterno ?? this.codigoInterno,
        acc: acc ?? this.acc,
        velocidad: velocidad ?? this.velocidad,
        terminal: terminal ?? this.terminal,
        kilometrajeAcum: kilometrajeAcum ?? this.kilometrajeAcum,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
        fecha: fecha ?? this.fecha,
        fechaEncendido: fechaEncendido ?? this.fechaEncendido,
        fechapagado: fechapagado ?? fechapagado,
        kilometrajeAcumuladoAyer:
            kilometrajeAcumuladoAyer ?? this.kilometrajeAcumuladoAyer,
        kilometrajeAcumuladoMes:
            kilometrajeAcumuladoMes ?? this.kilometrajeAcumuladoMes,
        direccionTramaActual: direccionTramaActual ?? this.direccionTramaActual,
        nombreConductor: nombreConductor ?? this.nombreConductor,
        imagenConductor: imagenConductor ?? this.imagenConductor,
        imeil: imeil ?? this.imeil,
        sim: sim ?? this.sim,
        kmgalon: kmgalon ?? this.kmgalon,
      );

  factory Auto.fromJson(Map<String, dynamic> json) => Auto(
        idVehiculo: json["id_vehiculo"],
        placa: json["placa"],
        codigoInterno: json["codigo_interno"],
        acc: json["ACC"] != null ? json["ACC"] : 0,
        velocidad: json["velocidad"] != null ? json["velocidad"] : 0,
        terminal: json["terminal"], // Proporcionar un valor por defecto
        fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
        fechaEncendido: json['fechaEncendido'] != null
            ? DateTime.parse(json['fechaEncendido'])
            : null,
        fechapagado: json['fechapagado'] != null
            ? DateTime.parse(json['fechapagado'])
            : null,
        latitud: json['latitud'],
        longitud: json['longitud'],
        kilometrajeAcum: json["kilometraje_acum"] != null
            ? json["kilometraje_acum"]?.toDouble()
            : 0,

        kilometrajeAcumuladoAyer: json["kilometraje_acumulado_ayer"] != null
            ? json["kilometraje_acumulado_ayer"]?.toDouble()
            : 0,

        kilometrajeAcumuladoMes: json["kilometraje_acumulado_mes"] != null
            ? json["kilometraje_acumulado_mes"]?.toDouble()
            : 0,
        //add
        fechaTramaActual: json['fechaTramaActual'],
        direccionTramaActual: json['direccionTramaActual'],
        nombreConductor:
            json['nombre_conductor'] != null ? json['nombre_conductor'] : '',
        imagenConductor:
            json['imagen_conductor'] != null ? json['imagen_conductor'] : '',
        imeil: json['imeil'],
        sim: json['sim'],
        kmgalon: json["km_galon"] != null ? json["km_galon"] : 0,
      );

  Map<String, dynamic> toJson() => {
        "id_vehiculo": idVehiculo,
        "placa": placa,
        "codigo_interno": codigoInterno,
        "ACC": acc,
        "velocidad": velocidad,
        "terminal": terminal,
        "latitud": latitud,
        "longitud": longitud,
        "kilometraje_acum": kilometrajeAcum,
        "fecha_kilometraje_acum": fecha,
        //add
        'fechaTramaActual': fechaTramaActual,
        "kilometraje_acumulado_ayer": kilometrajeAcumuladoAyer,
        "kilometraje_acumulado_mes": kilometrajeAcumuladoMes,

        "direccionTramaActual": direccionTramaActual,
        "nombreConductor": nombreConductor,
        "imagenConductor": imagenConductor,
        "imeil": imeil,
        "sim": sim,
        "km_galon": kmgalon,
      };
}
