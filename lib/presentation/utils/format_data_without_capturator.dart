import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

String formatFechaWithOutCapturador(DateTime fecha) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(fecha);

  String formattedTime = DateFormat('HH:mm').format(fecha);

  if (difference.inDays >= 1) {
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    return '${days} D / ${hours} Hr';
  }
  return '${formattedTime} Hr';
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
