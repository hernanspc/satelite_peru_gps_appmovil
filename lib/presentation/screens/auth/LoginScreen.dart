import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/app_theme.dart';
import 'package:satelite_peru_gps/presentation/components/constant/app_text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';
import 'package:satelite_peru_gps/presentation/components/buttons/rounded_button.dart';
import 'package:satelite_peru_gps/presentation/components/inputs/rounded_input_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  static const nameScreen = "login_screen";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isChecked = false;

  List<UrlOption> urlOptions = [
    UrlOption(displayName: 'FlotaBus', url: 'https://flotabus.com/'),
    UrlOption(displayName: 'MiBus', url: 'https://mibus.pe/'),
  ];

  String? selectedUrl;
  int selectedIndex = 0; // Índice inicial por defecto (0 para 'FlotaBus')

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
    _loadSavedUserPassword();
    _loadSavedUrl(); // Cargar URL seleccionada
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('API_URL_PREF');

    setState(() {
      if (savedUrl != null) {
        // Encuentra el índice de la URL guardada
        selectedIndex =
            urlOptions.indexWhere((option) => option.url == savedUrl);
        // Si no encuentra el índice, selecciona 'MiBus' por defecto
        if (selectedIndex == -1) {
          selectedIndex = 1; // Índice de 'MiBus'
        }
      } else {
        // Si no hay una URL guardada, selecciona 'MiBus' por defecto
        selectedIndex = 1;
      }
      selectedUrl = urlOptions[selectedIndex].url; // URL seleccionada
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  void _showUrlDialog(BuildContext context, bool isLightMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.white : const Color(0xff18191A),
          title: Text(
            'Configuración de API URL',
            style: TextStyle(
                fontSize: 16, color: isLightMode ? Colors.black : Colors.white),
          ),
          // content: SizedBox(
          //   height: 150,
          //   child: CupertinoPicker(
          //     itemExtent: 30,
          //     onSelectedItemChanged: (int value) {
          //       setState(() {
          //         selectedUrl = urlOptions[value].url;
          //       });
          //     },
          //     children: urlOptions.map((option) {
          //       return Text(
          //         option.displayName,
          //         style: TextStyle(
          //             color: isLightMode ? Colors.black : Colors.white),
          //       );
          //     }).toList(),
          //   ),
          // ),
          content: SizedBox(
            height: 150,
            child: CupertinoPicker(
              itemExtent: 30,
              scrollController: FixedExtentScrollController(
                initialItem: selectedIndex, // Establecer el índice inicial
              ),
              onSelectedItemChanged: (int value) {
                setState(() {
                  selectedIndex = value;
                  selectedUrl = urlOptions[value].url;
                });
              },
              children: urlOptions.map((option) {
                return Text(
                  option.displayName,
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (selectedUrl != null) {
                  _saveUrlToStorage(selectedUrl!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUrlToStorage(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('API_URL_PREF', url);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isLightMode ? AppTheme.white : const Color(0xff18191A),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Image.asset('assets/icon/sp.png',
                                      width: 100, height: 100),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "MIBUS APP",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xffDA2C26),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RoundedInputField(
                              hintText: "Empresa",
                              icon: Ionicons.bus,
                              onChange: (value) {},
                              controller: _empresaController,
                            ),
                            RoundedInputField(
                              controller: _userController,
                              hintText: "Usuario",
                              icon: Ionicons.person_circle,
                              onChange: (value) {},
                            ),
                            RoundedInputField(
                              isPassword: true,
                              controller: _passwordController,
                              hintText: "Contraseña",
                              icon: Icons.lock_person_sharp,
                              onChange: (value) {},
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  side: const BorderSide(
                                    color: Color(0xff6456FF),
                                    width: 2,
                                  ),
                                  activeColor: const Color(0xff6456FF),
                                  checkColor: Colors.white,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      _saveUserPassword(
                                        _passwordController.text.trim(),
                                      );
                                    } else {
                                      _deleteUserPassword();
                                    }
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                                Text(
                                  'Recordarme',
                                  style: TextStyle(
                                      color: brightness == Brightness.light
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: RoundedButton(
                                isLoading: isLoading,
                                text: "INGRESAR",
                                press: authService.autenticando && isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        final loginOk =
                                            await authService.signIn(
                                          _userController.text.trim(),
                                          _passwordController.text.trim(),
                                          _empresaController.text.trim(),
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (loginOk == true) {
                                          _saveUsername(
                                              _userController.text.trim(),
                                              _empresaController.text.trim());
                                          FocusScope.of(context).unfocus();
                                          context.go('/home_screen');
                                          _saveUserPasswordTemp(
                                            _passwordController.text.trim(),
                                          );
                                        } else {
                                          _passwordController.text = "";
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(' $loginOk'),
                                              duration: const Duration(
                                                milliseconds: 2000,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                color: const Color(0xff6456FF),
                              ),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: _launchUrl,
                              child: Text(
                                "Desarrollado por Satélite PerúⓇ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isLightMode
                                      ? const Color(0xff3684CC)
                                      : const Color.fromARGB(255, 63, 145, 221),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  color: brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showUrlDialog(context, isLightMode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse('https://sateliteperu.com/');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _loadSavedUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedUserEmpresa = prefs.getString('empresa');

    if (savedUsername != null) {
      setState(() {
        _userController.text = savedUsername;
      });
    }
    if (savedUserEmpresa != null) {
      setState(() {
        _empresaController.text = savedUserEmpresa;
      });
    }
  }

  Future<void> _saveUsername(String username, String empresa) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('empresa', empresa);
  }

  Future<void> _saveUserPassword(String userPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', userPassword);
  }

  void _saveUserPasswordTemp(String userPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempPassword', userPassword);
  }

  Future<void> _deleteUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('password');
  }

  void _loadSavedUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString('password');
    if (savedPassword != null) {
      setState(() {
        _passwordController.text = savedPassword;
        isChecked = true;
      });
    }
  }
}

class UrlOption {
  final String displayName;
  final String url;

  UrlOption({required this.displayName, required this.url});
}
