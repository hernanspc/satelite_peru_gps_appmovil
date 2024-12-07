import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:satelite_peru_gps/data/global/environment.dart';
import 'package:satelite_peru_gps/domains/models/authmodels/UserResponse.dart';
import 'package:satelite_peru_gps/domains/models/authmodels/Usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthService with ChangeNotifier {
  final _storage = new FlutterSecureStorage();
  bool _autenticando = false;

  Usuario? userSession;

  AuthStatus authStatus = AuthStatus.checking;
  AuthStatus get authStatusState => authStatus;

  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  String? _email;
  String? get email => _email;
  void setEmail(String? email) {
    _email = email;
    notifyListeners();
  }

  // Getters del token de forma estática
  static Future<String?> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  void guardarDatosUsuario(
      String email, String idEmpresa, String idUsuario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('idEmpresa', idEmpresa);
    await prefs.setString('idUsuario', idUsuario);
  }

  Future<String?> getEmailFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  Future signIn(String username, String password, String empresa) async {
    autenticando = true;
    final data = {
      'username': username,
      'password': password,
      'empresa': empresa,
    };
    final apiUrl = await Environment.apiUrl; // Resuelve la URL correcta
    print('FACTORIAurl signIn1 ${apiUrl}');
    try {
      var url = Uri.parse('${apiUrl}api/users/login');
      print('FACTORIA signIn2 $url');

      final resp = await http.post(
        url,
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print('|auth_service| api: url/user/login 🌟 ${resp.body}');
      // print('|statusCode url/user/login 🌟 ${resp.statusCode}');

      this.autenticando = false;
      if (resp.statusCode == 200) {
        final loginResponse = userResponseFromJson(resp.body);
        userSession = loginResponse.usuario;
        userSession!.token = loginResponse.token;

        await _saveToken(loginResponse.token);
        print('💥 your usersession: ${userSession}');
        guardarDatosUsuario(userSession!.email ?? '',
            '${userSession!.idEmpresa}', '${userSession!.id}');
        print('💥 your token: ${userSession!.token}');

        return true;
      } else {
        // return false;
        final resBody = jsonDecode(resp.body);
        print(' resBody error: ${resBody}');
        //
        // 422 else array

        return resBody['message'];
      }
    } catch (e) {
      print('Error catch signIn : ${e}');
      return false;
    }
  }

  Future signInWithToken(String username, String password) async {
    this.autenticando = true;
    final data = {
      'username': username,
      'password': password,
    };
    final apiUrl = await Environment.apiUrl; // Resuelve la URL correcta
    try {
      print('FACTORIA signInWithToken ${apiUrl}');
      var url = Uri.parse('${apiUrl}api/users/login-with-token');
      final resp = await http.post(
        url,
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
        },
      );

      this.autenticando = false;
      if (resp.statusCode == 200) {
        final loginResponse = userResponseFromJson(resp.body);
        userSession = loginResponse.usuario;
        userSession!.token = loginResponse.token;
        setEmail(userSession!.email);
        await _saveToken(loginResponse.token);
        print('💥 your token: ${userSession?.token}');

        return true;
      } else {
        // return false;
        final resBody = jsonDecode(resp.body);
        return resBody['message'];
      }
    } catch (e) {
      print('Error catch signIn : ${e}');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token') ?? '';
    try {
      if (token.isNotEmpty) {
        // Verifica si el token ha expirado
        if (!JwtDecoder.isExpired(token)) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          print('decodedToken: $decodedToken');
          // Asegúrate de que el token tenga la información que necesitas
          if (decodedToken.containsKey('password') &&
              decodedToken.containsKey('name')) {
            final usuario = decodedToken['name'];
            final password = decodedToken['password'];

            // final reLoginOk =
            //     await signIn(usuario, password, savedUserEmpresa!);
            String? email = await getEmailFromSharedPreferences();

            if (password != null) {
              setEmail(email);
              return true;
            }
            return false;
          } else {
            return false;
          }
        } else {
          print('token a expired!');
          await logout();
          return false;
        }
      } else {
        print('token is null!');
        await logout();
        return false;
      }
    } catch (e) {
      // Si ocurre algún error durante la solicitud, devuelve false
      print('Error al validar el token: $e');
      await logout();
      return false;
    }
  }

  Future _saveToken(String? token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
