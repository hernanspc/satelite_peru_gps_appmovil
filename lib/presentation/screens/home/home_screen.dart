import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/app_theme.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:satelite_peru_gps/data/services/mqtt_service.dart';
import 'package:satelite_peru_gps/presentation/utils/format_data_without_capturator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // AnimationController? animationController;
  late CarsService _carsService;
  bool _isLoading = true;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  late MqttService _mqttService;
  StreamSubscription<Map<String, dynamic>>? _mqttSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carsService = Provider.of<CarsService>(context, listen: false);

    _loadAutos();
  }

  Future<void> _loadAutos() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? idUsuario = prefs.getString('idUsuario');
    final authService = Provider.of<AuthService>(context, listen: false);
    final idUsuario = authService.userSession?.id;
    print('->in _loadAutos ${idUsuario}');

    await _carsService.getAutos('${idUsuario.toString()}');
    setState(() {
      _isLoading = false;
    });
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    await _carsService.getAddressesList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  void initState() {
    super.initState();

    _mqttService = MqttService();

    _mqttSubscription = _mqttService.autoDataStream.listen((data) {
      print('Respuesta MQTT recibida: $data');
      _carsService.updateAutosWithData(data);
    });

    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    await _mqttService.connect(context);
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0Xff4737FF),
        foregroundColor: Colors.white,
        title: Text(
          'Vehiculos',
        ),
      ),
      backgroundColor: isLightMode == true ? AppTheme.white : Color(0xff18191A),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color:
                    isLightMode == true ? Colors.grey[200] : Color(0xff3A3B3C),
                borderRadius: BorderRadius.circular(50),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                    color: isLightMode == true ? Colors.black : Colors.white),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  prefixIcon: _searchQuery.isEmpty
                      ? Icon(
                          Icons.search,
                          color: isLightMode == true
                              ? Colors.grey
                              : Color(0xffAEB1B6),
                        )
                      : null,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearSearch,
                          color: isLightMode == true
                              ? Colors.grey
                              : Color(0xffAEB1B6),
                        )
                      : null,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      fontSize: 14,
                      color: isLightMode == true
                          ? Colors.grey
                          : Color(0xffAEB1B6)),
                  hintText: "Buscar Placa",
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Consumer<CarsService>(
                  builder: (context, carsService, child) {
                    if (carsService.autos.isEmpty) {
                      return const Center(
                          child: Text('No se encontraron autos disponibles'));
                    }

                    final filteredAutos = carsService.autos.where((auto) {
                      // Normaliza la consulta de búsqueda para que coincida sin importar mayúsculas o minúsculas
                      final searchQuery =
                          _searchQuery.replaceAll('-', '').toLowerCase();

                      // Reemplaza el guión de la placa si existe
                      final placa = auto.placa?.replaceAll('-', '');

                      // Verifica si la placa (con o sin guion) o el código interno del auto contienen la consulta de búsqueda
                      return (placa != null &&
                              placa
                                  .replaceAll('-', '')
                                  .toLowerCase()
                                  .contains(searchQuery)) ||
                          (auto.codigoInterno != null &&
                              auto.codigoInterno!
                                  .toLowerCase()
                                  .contains(searchQuery));
                    }).toList();

                    return Expanded(
                      child: RefreshIndicator(
                        backgroundColor:
                            isLightMode ? Colors.grey[200] : Color(0xff3A3B3C),
                        onRefresh: _loadAutos,
                        child: ListView.builder(
                          itemCount: filteredAutos.length,
                          itemBuilder: (context, index) {
                            final auto = filteredAutos[index];
                            final address =
                                carsService.autoAddresses[auto.placa ?? ''] ??
                                    'Obteniendo dirección...por favor espere.';

                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              padding: EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                color: isLightMode == true
                                    ? AppTheme.white
                                    : Color(
                                        0xff242526), // Color de fondo del contenedor
                                shadows: [
                                  BoxShadow(
                                    color: isLightMode == true
                                        ? Colors.grey.withOpacity(0.5)
                                        : Colors.black.withOpacity(
                                            0.2), // Color de sombra
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(
                                      0,
                                      3,
                                    ), // Cambia la posición de la sombra
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                collapsedIconColor: Colors.purple,
                                iconColor: Colors.orange,
                                // leading: Icon(Icons.local_taxi),
                                tilePadding: EdgeInsets.all(
                                  0,
                                ), // Elimina los bordes del ExpansionTile
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Personaliza el radio de los bordes del ExpansionTile
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // Personaliza el radio de los bordes cuando está colapsado
                                ),
                                title: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            auto.codigoInterno != null
                                                ? 'PD${auto.codigoInterno}'
                                                : '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            auto.placa ?? 'No disponible',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.power_settings_new,
                                                color: auto.acc != null
                                                    ? auto.acc == 1
                                                        ? Colors.green[300]
                                                        : Colors.red
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              //TODO: MODIFICAR FECHA_ENCENDIDO : FECHA_APAGADO
                                              Text(
                                                '${auto.acc != null ? auto.acc == 1 ? formatFechaWithOutCapturador(auto.fechaEncendido ?? DateTime.now()) : formatFechaWithOutCapturador(auto.fechapagado ?? DateTime.now()) : ''}',
                                                style: TextStyle(
                                                  color: isLightMode == true
                                                      ? null
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/app/busList.png',
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: auto.velocidad ==
                                                                  null ||
                                                              auto.velocidad ==
                                                                  0 ||
                                                              auto.acc == 0
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${auto.acc != 1 ? '0' : auto.velocidad} km / h',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Hoy',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  Text(
                                                    // '${auto.kilometrajeAcum.toStringAsFixed(2)} km',
                                                    '${auto.kilometrajeAcum == 0 ? '0' : auto.kilometrajeAcum.toStringAsFixed(2)} km',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(
                                                              0.8,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Ayer',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${auto.kilometrajeAcumuladoAyer?.toInt()} km',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Mes',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${auto.kilometrajeAcumuladoMes?.toInt()} km',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          auto.nombreConductor
                                                  .toString()
                                                  .isNotEmpty
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .airline_seat_recline_normal_sharp),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Conductor:',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isLightMode ==
                                                                    true
                                                                ? null
                                                                : Colors.white
                                                                    .withOpacity(
                                                                        0.8),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '${auto.nombreConductor}',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: isLightMode ==
                                                                true
                                                            ? null
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                  ],
                                                )
                                              : SizedBox(),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Sentido: ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isLightMode == true
                                                          ? null
                                                          : Colors.white
                                                              .withOpacity(0.8),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: auto.terminal ==
                                                              'TERMINAL_FINAL'
                                                          ? Colors.red
                                                          : Colors
                                                              .blue, // Color de fondo rojo
                                                      shape: BoxShape
                                                          .circle, // Forma circular
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        size: 15,
                                                        auto.terminal ==
                                                                'TERMINAL_FINAL'
                                                            ? Icons
                                                                .arrow_downward
                                                            : Icons
                                                                .arrow_upward,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    '${auto.terminal == 'TERMINAL_FINAL' ? 'BAJADA' : 'SUBIDA'}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: auto.terminal ==
                                                              'TERMINAL_FINAL'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.pin_drop, size: 16),
                                              SizedBox(width: 5),
                                              Text(
                                                'Direccion:',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isLightMode == true
                                                      ? null
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            address.isNotEmpty == true
                                                ? address
                                                : 'No disponible',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              carsService.resetAutosHistorial();
                                              carsService.setSelectedAuto(auto);

                                              context.push(
                                                '/bus_map_view_screen',
                                                extra: {
                                                  'latitude': auto.latitud,
                                                  'longitude': auto.longitud,
                                                  'id_auto': auto.idVehiculo
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.location_pin,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.orange,
                                              backgroundColor: isLightMode
                                                  ? null
                                                  : Colors.white.withOpacity(
                                                      0.12,
                                                    ), // Color de fondo oscuro
                                            ),
                                          ),
                                          Text(
                                            'Ver mapa',
                                            style: TextStyle(
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              context.push(
                                                '/bus_map_historial',
                                                extra: {
                                                  'placa': auto.placa,
                                                  'id_vehiculo':
                                                      auto.idVehiculo,
                                                  'latitude': auto.latitud,
                                                  'longitude': auto.longitud,
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.history,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.orange,
                                              backgroundColor: isLightMode
                                                  ? null
                                                  : Colors.white.withOpacity(
                                                      0.12), // Color de fondo oscuro
                                            ),
                                          ),
                                          Text(
                                            'Historial',
                                            style: TextStyle(
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              context.push(
                                                '/bus_report_screen',
                                                extra: {
                                                  'placa': auto.placa,
                                                  'vehiculo_id':
                                                      auto.idVehiculo,
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.textsms,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.orange,
                                              backgroundColor: isLightMode
                                                  ? null
                                                  : Colors.white.withOpacity(
                                                      0.12,
                                                    ), // Color de fondo oscuro
                                            ),
                                          ),
                                          Text(
                                            'Reporte',
                                            style: TextStyle(
                                              color: isLightMode == true
                                                  ? null
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
