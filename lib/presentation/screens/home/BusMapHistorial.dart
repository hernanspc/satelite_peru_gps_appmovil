import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/data/services/reports_service.dart';
import 'package:satelite_peru_gps/presentation/components/app_bar/CustomAppBar.dart';

class BusMapHistorial extends StatefulWidget {
  const BusMapHistorial({super.key});

  @override
  _BusMapHistorialState createState() => _BusMapHistorialState();
}

class _BusMapHistorialState extends State<BusMapHistorial>
    with SingleTickerProviderStateMixin {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  List<LatLng> route = [];

  late LatLng _currentLocation;
  int _currentIndex = 0;
  Duration _duration = const Duration(seconds: 1);
  late MapController _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPaused = true;
  late String type = '';

  bool isTapTabBar = false;

// Agregar al inicio de la clase como variable de estado
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();

    _duration = Duration(seconds: (1 / _playbackSpeed).round());

    _currentLocation =
        isTapTabBar == false ? const LatLng(-12.0464, -77.0428) : route[0];
    _mapController = MapController();
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        double t = _animation.value;
        if (_currentIndex < route.length - 1) {
          LatLng startLocation = route[_currentIndex];
          LatLng endLocation = route[_currentIndex + 1];
          _currentLocation = _interpolate(startLocation, endLocation, t);
          final offset = Offset(0, -100);
          _mapController.move(
            _currentLocation,
            _mapController.camera.zoom,
            offset: offset,
          );
        }
      });
    });
    _animateCar();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _animateCar() {
    if (_currentIndex < route.length - 1 && !_isPaused) {
      _animationController.duration =
          Duration(seconds: (1 / _playbackSpeed).round());
      _animationController.forward(from: 0.0).then((_) {
        if (!_isPaused && _currentIndex < route.length - 1) {
          _currentIndex++;
          _animateCar();
        } else {
          setState(() {
            _isPaused = true;
          });
        }
      });
    }
  }

  void _togglePlaybackSpeed() {
    setState(() {
      // Rotar entre las opciones de velocidad
      int currentIndex = _speedOptions.indexOf(_playbackSpeed);
      _playbackSpeed = _speedOptions[(currentIndex + 1) % _speedOptions.length];

      // Si no está pausado, reiniciar la animación con la nueva velocidad
      if (!_isPaused) {
        _animationController.stop();
        _animateCar();
      }
    });
  }

  void _pauseAnimation() {
    setState(() {
      _isPaused = true;
    });
    _animationController.stop(); // Pausa la animación
  }

  Widget _buildPlayPauseButton() {
    return ElevatedButton.icon(
      onPressed: () {
        if (_isPaused) {
          setState(() {
            _isPaused = false;
          });
          _animateCar();
        } else {
          _pauseAnimation();
        }
      },
      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
      label: Text(_isPaused ? 'Reproducir' : 'Pausar'),
    );
  }

  // Modificar _buildPlayPauseButton para incluir el botón de velocidad
  Widget _buildPlayPauseControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (_isPaused) {
              setState(() {
                _isPaused = false;
              });
              _animateCar();
            } else {
              _pauseAnimation();
            }
          },
          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          label: Text(_isPaused ? 'Reproducir' : 'Pausar'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _togglePlaybackSpeed,
          child: Text(
            'x${_playbackSpeed.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  void _centerMap() {
    final zoomLevel = _mapController.camera.zoom;
    final offset = Offset(0, -100);
    _mapController.move(_currentLocation, zoomLevel, offset: offset);
  }

  LatLng _interpolate(LatLng start, LatLng end, double t) {
    double lat = start.latitude + (end.latitude - start.latitude) * t;
    double lng = start.longitude + (end.longitude - start.longitude) * t;
    return LatLng(lat, lng);
  }

  int _selectedTabIndex = -1; // Estado para el botón seleccionado

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    final String placa = extra['placa'] as String;
    final int idVehiculo = extra['id_vehiculo'] as int;
    final reportsService = Provider.of<ReportsService>(context);

    final eventDetailsData = reportsService.eventDetails;

    void handleTabChange(int index) async {
      setState(() {
        route = [];
      });

      switch (index) {
        case 0:
          type = '30_minutos';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();

          break;
        case 1:
          type = '1_hora';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();

          break;
        case 2:
          type = '2_horas';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();
          break;
        case 3:
          type = '7_horas';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();
          break;
        case 4:
          type = 'hoy';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();
          break;
        case 5:
          type = 'ayer';
          await reportsService.getLocationsRoute(
              idVehiculo: idVehiculo, type: type);
          setState(() {
            route = reportsService.routeLocations;
            _currentLocation = reportsService.routeLocations[0];
            _currentIndex = 0; // Reiniciar índice
            _isPaused = true; // Pausado por defecto
          });
          _centerMap();
          break;
        default:
          print("Acción para la pestaña ");
          break;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Historial placa: $placa'),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 13.0,
                    minZoom: 2,
                    maxZoom: 20,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          strokeWidth: 4.0,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    if (route.isNotEmpty)
                      MarkerLayer(
                        markers: [
                          // Marcador para la última posición con el texto "A"
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: route.first, // Última posición en la ruta
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circulito
                                Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Texto "A"
                                const Text(
                                  "A",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: route.last, // Última posición en la ruta
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circulito
                                Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Texto "A"
                                const Text(
                                  "B",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    reportsService.isLoading
                        ? const SizedBox()
                        : _selectedTabIndex != -1
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 80),
                                child: MarkerLayer(
                                  markers: [
                                    Marker(
                                      rotate: true,
                                      width: 150.0,
                                      height: 50.0,
                                      point: _currentLocation,
                                      child: Card(
                                        color: eventDetailsData.isNotEmpty
                                            ? eventDetailsData[_currentIndex]
                                                        ['velocidad'] ==
                                                    0
                                                ? Colors.red
                                                : Colors.green
                                            : Colors.red,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              route.isEmpty
                                                  ? Container()
                                                  : Text(
                                                      '${eventDetailsData.isNotEmpty ? eventDetailsData[_currentIndex]['fecha'].toString().substring(11, 19) : ''}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                              Text(
                                                '${eventDetailsData.isNotEmpty ? eventDetailsData[_currentIndex]['velocidad'].toString() : '0'} km/h',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                    route.isNotEmpty
                        ? MarkerLayer(
                            markers: [
                              // Marker(
                              //   rotate: true,
                              //   width: 25.0,
                              //   height: 25.0,
                              //   point: _currentLocation,
                              //   child: Container(
                              //     child: Image.asset(
                              //       'assets/app/autobus.png',
                              //       width: 30.0,
                              //       height: 40.0,
                              //     ),
                              //   ),
                              // ),
                              Marker(
                                point: _currentLocation,
                                child: Transform.rotate(
                                  angle: int.tryParse(
                                          eventDetailsData[_currentIndex]
                                              ['variacion_grados'])! *
                                      (3.14159265359 /
                                          180), // Convertir grados a radianes
                                  child: Icon(
                                    Icons
                                        .navigation, // Ícono que representa la dirección
                                    size: 35,
                                    color: Colors.green[500],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _buildRoundButton(
                        icon: Icons.zoom_in,
                        onPressed: () {
                          _centerMap();
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        tooltip: 'Zoom In',
                      ),
                      const SizedBox(height: 10),
                      _buildRoundButton(
                        icon: Icons.zoom_out,
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                          _centerMap();
                        },
                        tooltip: 'Zoom Out',
                      ),
                      const SizedBox(height: 10),
                      _buildRoundButton(
                        icon: Icons.my_location,
                        onPressed: _centerMap,
                        tooltip: 'Center Map',
                      ),
                      const SizedBox(height: 10),
                      _buildRoundButton(
                          onPressed: () {
                            context.pop(1);
                          },
                          icon: Icons.home_filled,
                          tooltip: 'Regresar'),
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.35,
                  minChildSize: 0.1,
                  maxChildSize: 0.5,
                  controller: sheetController,
                  builder: (BuildContext context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Center(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                height: 4,
                                width: 40,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          SliverList.list(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'Seleccione un rango de tiempo',
                                // textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      // controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              _buildTabButton(0, '30 m',
                                                  () => handleTabChange(0)),
                                              _buildTabButton(1, '1 hr',
                                                  () => handleTabChange(1)),
                                              _buildTabButton(2, '2 hr',
                                                  () => handleTabChange(2)),
                                              _buildTabButton(3, '7 hr',
                                                  () => handleTabChange(3)),
                                              _buildTabButton(4, 'Hoy',
                                                  () => handleTabChange(4)),
                                              _buildTabButton(
                                                5,
                                                'Ayer',
                                                () => handleTabChange(5),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SliverList.list(
                            children: [
                              const SizedBox(height: 20),
                              reportsService.isLoading
                                  ? const Text(
                                      'Espere un momento...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    )
                                  : route.isNotEmpty
                                      ? Column(
                                          children: [
                                            // _buildPlayPauseButton(),
                                            _buildPlayPauseControls(),
                                            const SizedBox(height: 20),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Fecha movimiento',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${eventDetailsData.isNotEmpty ? eventDetailsData[_currentIndex]['fecha'].toString().substring(11, 19) : ''}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ])
                                          ],
                                        )
                                      : _selectedTabIndex != -1
                                          ? const Text(
                                              'Rutas no encontrada',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            )
                                          : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir cada botón, toma el índice y el texto
  Widget _buildTabButton(int index, String label, Function() handleTabChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: FilledButton(
        onPressed: () {
          handleTabChange();
          setState(() {
            _selectedTabIndex = index; // Cambiar el índice seleccionado
          });
        },
        style: FilledButton.styleFrom(
          backgroundColor: _selectedTabIndex == index
              ? Colors.greenAccent[700]
              : Colors.blueGrey, // Cambiar color según la selección
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: const BoxDecoration(
          color: Color(0Xff4737FF),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
          tooltip: tooltip,
        ),
      ),
    );
  }
}
