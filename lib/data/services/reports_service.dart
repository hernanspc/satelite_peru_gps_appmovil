import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:satelite_peru_gps/data/global/environment.dart';
import 'package:satelite_peru_gps/domains/models/autos_models/LocationsResponse.dart';

class ReportsService with ChangeNotifier {
  bool _isLoading = false;

  List<LatLng> routeLocations = [];

  List<Map<String, dynamic>> eventDetails = [];

  bool get isLoading => _isLoading;

  Future<LocationsResponse> getLocationsRoute({
    required String type,
    required int idVehiculo,
  }) async {
    _isLoading = true;
    notifyListeners(); // Notifica a los oyentes que el estado ha cambiado

    final apiUrl = await Environment.apiUrl; // Resuelve la URL correcta
    print('FACTORIA getLocationsRoute $apiUrl');
    final url = Uri.parse(
        '${apiUrl}api/reportes/eventosRecorrido?type=$type&vehiculo_id=$idVehiculo');
    print('FACTORIA getLocationsRoute $url');

    try {
      routeLocations = [];
      eventDetails = [];
      final response = await http.post(
        url,
        // body: {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          final eventos = data['reporte']['eventos'] as List;

          // Mapear los eventos a una lista de mapas con fecha y velocidad
          eventDetails = eventos.map<Map<String, dynamic>>((evento) {
            return {
              'fecha': evento[
                  'fecha'], // Asegúrate de que 'fecha' está en el formato adecuado
              'velocidad':
                  evento['velocidad'] ?? 0, // Asigna 0 si 'velocidad' es null
              'variacion_grados': evento['variacion_grados']
              // int.tryParse(evento['variacion_grados'] ?? '') ?? 0,
            };
          }).toList();

          routeLocations = eventos.map<LatLng>((evento) {
            return LatLng(
              evento['latitud'],
              evento['longitud'],
            );
          }).toList();

          // Retorna un objeto LocationsResponse
          return LocationsResponse.fromJson(data['reporte']);
        } else {
          // Retorna una respuesta vacía o maneja el caso de fallo según sea necesario
          print('API response indicates failure');
          // Puedes considerar lanzar una excepción en lugar de retornar null
          throw Exception('API response indicates failure');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        // Puedes lanzar una excepción aquí para manejar el error en el nivel superior
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error catch getAutos: $e');
      // Puedes lanzar una excepción aquí para manejar el error en el nivel superior
      throw Exception('Error catch getAutos: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a los oyentes que el estado ha cambiado
    }
  }
}
