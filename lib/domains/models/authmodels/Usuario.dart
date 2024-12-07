// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  String? token;
  int? id;
  String? name;
  String? email;
  String? password;
  String? tipoDocumento;
  int? numeroDocumento;
  dynamic? fechaNacimiento;
  String? direccion;
  dynamic? gradoInstruccion;
  String? telefono;
  dynamic? estadoCivil;
  String? rememberToken;
  int? idEmpresa;
  String? nombres;
  String? role;

  Usuario({
    this.token,
    this.id,
    this.name,
    this.email,
    this.password,
    this.tipoDocumento,
    this.numeroDocumento,
    this.fechaNacimiento,
    this.direccion,
    this.gradoInstruccion,
    this.telefono,
    this.estadoCivil,
    this.rememberToken,
    this.idEmpresa,
    this.nombres,
    this.role,
  });

  Usuario copyWith({
    String? token,
    int? id,
    String? name,
    String? email,
    String? password,
    String? tipoDocumento,
    int? numeroDocumento,
    dynamic fechaNacimiento,
    String? direccion,
    dynamic gradoInstruccion,
    String? telefono,
    dynamic estadoCivil,
    String? rememberToken,
    int? idEmpresa,
    String? nombres,
    String? role,
  }) =>
      Usuario(
        token: token ?? this.token,
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        tipoDocumento: tipoDocumento ?? this.tipoDocumento,
        numeroDocumento: numeroDocumento ?? this.numeroDocumento,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        direccion: direccion ?? this.direccion,
        gradoInstruccion: gradoInstruccion ?? this.gradoInstruccion,
        telefono: telefono ?? this.telefono,
        estadoCivil: estadoCivil ?? this.estadoCivil,
        rememberToken: rememberToken ?? this.rememberToken,
        idEmpresa: idEmpresa ?? this.idEmpresa,
        nombres: nombres ?? this.nombres,
        role: role ?? this.role,
      );

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        token: json["token"],
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        tipoDocumento: json["tipo_documento"],
        numeroDocumento: json["numero_documento"],
        fechaNacimiento: json["fecha_nacimiento"],
        direccion: json["direccion"],
        gradoInstruccion: json["grado_instruccion"],
        telefono: json["telefono"],
        estadoCivil: json["estado_civil"],
        rememberToken: json["remember_token"],
        idEmpresa: json["Id_empresa"],
        nombres: json["nombres"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "tipo_documento": tipoDocumento,
        "numero_documento": numeroDocumento,
        "fecha_nacimiento": fechaNacimiento,
        "direccion": direccion,
        "grado_instruccion": gradoInstruccion,
        "telefono": telefono,
        "estado_civil": estadoCivil,
        "remember_token": rememberToken,
        "Id_empresa": idEmpresa,
        "nombres": nombres,
        "role": role,
      };
}
