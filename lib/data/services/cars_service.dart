import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:satelite_peru_gps/data/global/environment.dart';
import 'package:satelite_peru_gps/domains/models/autos_models/Auto.dart';
import 'package:satelite_peru_gps/domains/models/autos_models/ReportsReponse.dart';

class CarsService with ChangeNotifier {
  bool _isLoading = false;

  List<Auto> autos = [];
  List<Auto> autosHistorial = [];
  Map<String, String> autoAddresses = {};

  late Auto _selectedAuto;

  Auto get selectedAuto => _selectedAuto;

  // Método para establecer el auto seleccionado
  void setSelectedAuto(Auto auto) {
    _selectedAuto = auto;
    notifyListeners(); // Notificar a los escuchadores sobre el cambio
  }

  Future<void> getAutos(String idUsuario) async {
    _isLoading = true;

    final data = {'id_usuario': idUsuario};
    final apiUrl = await Environment.apiUrl; // Resuelve la URL correcta
    print('getAutos API URL: ${apiUrl}');
    print('getAutos data : ${data}');

    try {
      var url = Uri.parse('${apiUrl}api/cars/getAutos');
      final resp = await http.post(
        url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(resp.body);
        if (responseData['success']) {
          final List<dynamic> autosData = responseData['autos'];
          autos = autosData.map((data) => Auto.fromJson(data)).toList();
          print(' ********************************');
          print('🌈 ${autos.length}🌈🌈🌈🌈🌈🌈');
        } else {
          print('Error: ${responseData['message']}');
          autos = [];
        }
      } else {
        print('Error: ${resp.statusCode}');
        autos.clear();
      }
    } catch (e) {
      print('Error catch getAutos: $e');
      autos.clear();
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<String?> obtenerDireccion(double lat, double lon) async {
    try {
      // Define la URL y realiza la solicitud GET
      var url = Uri.parse(
          'http://ironmaps.com/nominatim/reverse.php?format=json&limit=1&lat=${lat}&lon=${lon}');
      final response = await http.get(url);

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      // Captura cualquier excepción que ocurra durante la solicitud
      print('Error al obtener la dirección: $e');
      return '';
    }
  }

  Future<void> getAddressesList() async {
    print('autos lenght ${autos.length}');

    for (var auto in autos) {
      if (auto.latitud != null && auto.longitud != null) {
        try {
          final address = await obtenerDireccion(auto.latitud!, auto.longitud!);
          print('🍺rakim ${auto.codigoInterno} ${auto.placa} $address');

          autoAddresses[auto.placa ?? ''] = '${address}';
          auto.direccionTramaActual = '${address}';
        } catch (e) {
          print('Error obteniendo la dirección: $e');
        }
      }
    }
    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radio de la Tierra en metros
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distancia en metros
  }

  Future<void> updateAutosWithData(Map<String, dynamic> data) async {
    print('🍺h🍺 recibido updateAutosWithData : ${data}');
    int idVehiculoStream = data["id_vehiculo"];

    for (var auto in autos) {
      if (auto.idVehiculo == idVehiculoStream) {
        int accCapturador = data["ACC"] ?? 0;
        String terminalCapturador = data["terminal"];
        double kilometrajeAcumCapturador =
            data["kilometraje_acum"]?.toDouble() ?? 0.0;
        // Obtener las nuevas coordenadas de la trama actual
        double latitudCapturador = data["tramaActual"]["latitud"] ?? 0.0;
        double longitudCapturador = data["tramaActual"]["longitud"] ?? 0.0;
        int velocidadCapturador =
            int.parse(data["tramaActual"]["velocidad"].toString()) ?? 0;

        String fechaStr = data["tramaActual"]["fecha"] ?? '';
        DateTime fechaCapturador = DateTime.parse(fechaStr);

        String formattedTime = DateFormat('HH:mm').format(fechaCapturador);

        DateTime now = DateTime.now();
        Duration difference = now.difference(fechaCapturador);

        // double latitudLast = auto.latitud ?? null;
        // double longitudLast = auto.longitud ?? null;

        // Actualizar las coordenadas y la fecha del auto
        auto.latitud = latitudCapturador;
        auto.longitud = longitudCapturador;
        auto.fecha = fechaCapturador;
        auto.fechaTramaActual = '$formattedTime Hr';
        auto.acc = accCapturador;
        auto.velocidad = velocidadCapturador;
        auto.terminal = terminalCapturador;
        auto.kilometrajeAcum = kilometrajeAcumCapturador;

        String fechaTramaActualStr;
        if (difference.inDays >= 1) {
          int days = difference.inDays;
          int hours = difference.inHours % 24;
          fechaTramaActualStr = '${days} D / ${hours} Hr';
          auto.fechaTramaActual = fechaTramaActualStr;
        }

        // Actualizar la dirección del auto basado en la latitud y longitud capturadas
        final address = await getAddress(latitudCapturador, longitudCapturador);
        if (address != null) {
          auto.direccionTramaActual = address;
        }
        autoAddresses[auto.placa ?? ''] = '${address}';

        // if (latitudLast != null && longitudLast != null) {
        //   //ACTUALIZAR KM ACUMULADOS
        //   final distanciaRecorrida = _calulateKilometrajeAcumulados(
        //     latitudLast,
        //     longitudLast,
        //     auto.latitud,
        //     auto.longitud,
        //   );

        //   print('CHACA ${distanciaRecorrida}');
        //   // auto.kilometrajeAcum = kilometrajeAcumCapturador;
        //   auto.kilometrajeAcum += distanciaRecorrida;
        // }

        // print('🍺🍺🍺 actualizado: ${auto.toJson()}');
      }
    }
    // Solo si el idVehiculo del stream coincide con el seleccionado
    if (idVehiculoStream == _selectedAuto.idVehiculo) {
      print(
          'HB HERNAN - recibiste actualización ${_selectedAuto.velocidad} ${_selectedAuto.fecha} ${_selectedAuto.latitud} ${_selectedAuto.longitud}');

      if (autosHistorial.isNotEmpty) {
        final lastAuto = autosHistorial.last;
        final distance = calculateDistance(
          lastAuto.latitud,
          lastAuto.longitud,
          _selectedAuto.latitud,
          _selectedAuto.longitud,
        );

        print(
            'HB HERNAN Distancia entre la última ubicación y la actual: $distance metros');

        // Solo agregar al historial si la distancia es mayor a 2 metros
        if (distance <= 2) {
          print(
              'HB HERNAN Distancia menor a 2 metros, se ignora esta actualización');
          return; // Salir de la función sin guardar la trama actual
        }
      }
      // Crea una copia del estado actual del `selectedAuto`
      Auto autoCopy = Auto(
        codigoInterno: _selectedAuto.codigoInterno,
        fechaEncendido: _selectedAuto.fechaEncendido,
        fechapagado: _selectedAuto.fechapagado,
        kilometrajeAcumuladoAyer: _selectedAuto.kilometrajeAcumuladoAyer,
        kilometrajeAcumuladoMes: _selectedAuto.kilometrajeAcumuladoMes,
        placa: _selectedAuto.placa,
        idVehiculo: _selectedAuto.idVehiculo,
        latitud: _selectedAuto.latitud,
        longitud: _selectedAuto.longitud,
        fecha: _selectedAuto.fecha,
        fechaTramaActual: _selectedAuto.fechaTramaActual,
        direccionTramaActual: _selectedAuto.direccionTramaActual,
        acc: _selectedAuto.acc,
        velocidad: _selectedAuto.velocidad,
        terminal: _selectedAuto.terminal,
        kilometrajeAcum: _selectedAuto.kilometrajeAcum,
        imeil: _selectedAuto.imeil,
        kmgalon: _selectedAuto.kmgalon,
      );

      // Agrega la copia al historial y limita a los últimos 4 elementos
      if (autosHistorial.length >= 4) {
        autosHistorial.removeAt(0);
      }
      autosHistorial.add(autoCopy);
      print('HB HERNAN  Se guarda ubi');
      notifyListeners();
    }
    // Después de actualizar los datos, llamar a notifyListeners()
    notifyListeners();
  }

  double _calulateKilometrajeAcumulados(
    double latLast,
    double longLast,
    double lat,
    double long,
  ) {
    double theta = latLast - lat;
    double radianLat1 = degToRad(latLast);
    double radianLat2 = degToRad(lat);
    double radianTheta = degToRad(theta);

    double dist = sin(radianLat1) * sin(radianLat2) +
        cos(radianLat1) * cos(radianLat2) * cos(radianTheta);
    dist = acos(dist);
    dist = radToDeg(dist);
    dist = dist * 60 * 1.1515; // Distancia en millas

    return dist * 1.609344; // Convertir a kilómetros
  }

  /// Convierte grados a radianes
  double degToRad(double degree) {
    return degree * pi / 180.0;
  }

  /// Convierte radianes a grados
  double radToDeg(double radian) {
    return radian * 180.0 / pi;
  }

  void resetAutosHistorial() {
    autosHistorial.clear();
    notifyListeners(); // Notifica a los widgets que dependen de autosHistorial para que se actualicen.
  }

  Future<String?> getAddress(double lat, double lng) async {
    final url =
        'http://ironmaps.com/nominatim/reverse.php?format=json&limit=1&lat=${lat}&lon=${lng}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener la dirección: $e');
      return null;
    }
  }

  Future<ReportResponse?> getReportBus({
    required int idVehiculo,
    required String fecha,
    required String type,
    String? fechaEnd,
  }) async {
    // final url = 'https://mibus.pe/api/reportes/vueltasKilometraje'
    final params = {
      'fecha': fecha,
      'vehiculo_id': idVehiculo.toString(),
      'type': type,
      if (fechaEnd != null && fechaEnd.isNotEmpty) 'fecha_end': fechaEnd,
    };
    final apiUrl = await Environment.apiUrl; // Resuelve la URL correcta
    print('FACTORIA getReportBus apiUrl $apiUrl');
    try {
      var url = Uri.parse('${apiUrl}api/reportes/vueltasKilometraje');
      print('FACTORIA getReportBus apiUrl2 $url');
      final response = await http.post(
        url,
        body: params,
      );
      print('FACTORIA getReportBus => $response');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReportResponse.fromJson(data);
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener la dirección: $e');
      return null;
    }
  }

  bool get isLoading => _isLoading;
}
