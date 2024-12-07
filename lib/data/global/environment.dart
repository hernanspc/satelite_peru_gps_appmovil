import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Environment {
  static const String defaultApiUrl = "https://mibus.pe/";
  static const String apiUrlPrefKey = "API_URL_PREF";

  // static String apiUrl = "https://mibus.pe/";

  /// Obtiene la URL desde las preferencias almacenadas, o usa la predeterminada.
  static Future<String> get apiUrl async {
    final prefs = await SharedPreferences.getInstance();
    print('FACTORIA env $prefs');
    return prefs.getString(apiUrlPrefKey) ?? defaultApiUrl;
  }

  static const String API_KEY_MAP = "AIzaSyD7qxEuruaNBo8Pi_qvYrzOhYsghjIMetY";
}
