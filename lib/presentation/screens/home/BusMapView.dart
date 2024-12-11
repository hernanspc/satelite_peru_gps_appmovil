import 'dart:ui';
// import 'dart:math';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:satelite_peru_gps/presentation/components/markers/marker_bus.dart';

const MAPBOX_ACCESS_TOKEN =
    "pk.eyJ1IjoiaGVybmFuZGV2b3BzIiwiYSI6ImNseTE5ZHB5cTB1dWsya3Eyamhtem5pMDIifQ.O4be5VsKzbJRC9hWE1d-AQ";
const MAPBOX_STYLE = 'mapbox/streets-v12';
const MARKER_COLOR = Color(0xff3DC5A7);
const MARKER_SIZE_EXPANDED = 54.0;
const MARKER_SIZE_SHRINKED = 35.0;
const COUNT_UBICATIONS = 4;
final _myLocation = LatLng(-11.973808, -76.918822);
int duration = 0;

class BusMapView extends StatefulWidget {
  const BusMapView({super.key});

  @override
  State<BusMapView> createState() => _BusMapViewState();
}

class _BusMapViewState extends State<BusMapView> with TickerProviderStateMixin {
  final _pageController = PageController();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  late final AnimationController _animationController;
  bool isFocusBus = true;
  late final MapController _mapController;
  bool darkMode = false;
  TabController? _tabController;
  late LatLng markerBusInitial;
  bool isSelectedMarkerBus = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animationController.repeat(reverse: true);
    // Inicializamos el TabController con el índice 3 (cuarta pestaña)
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    _pageController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        isFocusBus = false;
      });
    }
  }

  void zoomIn() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void zoomOut() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom - 1);
  }

  int selectedMarkerIndex = -1;

  @override
  Widget build(BuildContext context) {
    final busSelectProvider = Provider.of<CarsService>(context).selectedAuto;
    final busRecordProvider = Provider.of<CarsService>(context).autosHistorial;

    final GoRouterState state = GoRouterState.of(context);
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;

    final double initialLatitudeProp = extra['latitude'] as double;
    final double initialLongitudeProp = extra['longitude'] as double;
    markerBusInitial = LatLng(initialLatitudeProp, initialLongitudeProp);

    markerBusInitial = LatLng(busSelectProvider.latitud ?? initialLatitudeProp,
        busSelectProvider.longitud ?? initialLongitudeProp);

    final polylinePoints = [
      ...busRecordProvider.map((e) => LatLng(e.latitud!, e.longitud!)),
      markerBusInitial,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('FIL ${_mapController.camera.zoom}');

      if (isFocusBus) {
        _mapController.move(
          markerBusInitial,
          _mapController.camera.zoom,
          offset: Offset(0, -100),
        );
      }
    });

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0Xff4737FF),
        foregroundColor: Colors.white,
        title: Text('Placa: ${busSelectProvider.placa}'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                darkMode = !darkMode;
              });
            },
            icon: Icon(darkMode ? Icons.wb_sunny : Icons.brightness_2),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onPositionChanged: _onMapPositionChanged,
              initialZoom: 20.0,
              minZoom: 4,
              maxZoom: 20,
              initialCenter: LatLng(initialLatitudeProp, initialLongitudeProp),
            ),
            children: [
              _darkModeContainerIfEnabled(
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                  // 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  // urlTemplate:
                  //     'https://api.mapbox.com/styles/v1/{styleId}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  // additionalOptions: const {
                  //   'accessToken': MAPBOX_ACCESS_TOKEN,
                  //   'styleId': MAPBOX_STYLE,
                  // },
                ),
              ),

              //Ruta trazada
              if (busRecordProvider.isNotEmpty)
                _buildPolylineLayer(polylinePoints),
              //Indicador de Vehiculo
              if (busRecordProvider.length > 1)
                MarkerLayer(
                    markers: busRecordProvider
                        .take(busRecordProvider.length - 1)
                        .map(
                  (element) {
                    final LatLng point =
                        LatLng(element.latitud!, element.longitud!);
                    return Marker(
                      point: point,
                      rotate: true,
                      width: selectedMarkerIndex ==
                              busRecordProvider.indexOf(element)
                          ? MARKER_SIZE_EXPANDED
                          : MARKER_SIZE_SHRINKED,
                      height: selectedMarkerIndex ==
                              busRecordProvider.indexOf(element)
                          ? MARKER_SIZE_EXPANDED
                          : MARKER_SIZE_SHRINKED,
                      child: GestureDetector(
                        onTap: () {
                          // Mostrar el marcador en la parte superior
                          sheetController.animateTo(
                            0.5,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.linear,
                          );
                          // Acción al hacer clic en el marcador
                          setState(() {
                            print(
                                'VIHINDEX ${busRecordProvider.indexOf(element)} ${busRecordProvider.indexOf(element)}'); // POSICION 0 SIEMPRE SERA EL TRAK
                            selectedMarkerIndex =
                                busRecordProvider.indexOf(element);
                          });
                        },
                        child: Icon(
                          selectedMarkerIndex ==
                                  busRecordProvider.indexOf(element)
                              ? Icons.location_on_rounded
                              : Icons.location_on_rounded,
                          color: selectedMarkerIndex ==
                                  busRecordProvider.indexOf(element)
                              ? Colors.red
                              : Colors.green[600],
                          size: selectedMarkerIndex ==
                                  busRecordProvider.indexOf(element)
                              ? MARKER_SIZE_EXPANDED
                              : MARKER_SIZE_SHRINKED,
                        ),
                      ),
                    );
                  },
                ).toList()),

              busSelectProvider.imagenConductor.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: MarkerLayer(
                        markers: [
                          Marker(
                            rotate: true,
                            width: 35,
                            height: 35.0,
                            point: markerBusInitial,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Stack(
                                        children: [
                                          InteractiveViewer(
                                            child: Image.network(
                                              busSelectProvider.imagenConductor,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: 24,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cierra el diálogo
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                    busSelectProvider.imagenConductor),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: MarkerLayer(
                  markers: [
                    Marker(
                      rotate: true,
                      width: 110,
                      height: 30.0,
                      point: markerBusInitial,
                      child: Column(
                        children: [
                          Card(
                            color: busSelectProvider.acc != null
                                ? busSelectProvider.acc == 1
                                    ? darkMode
                                        ? Colors.green.withOpacity(0.6)
                                        : Colors.green[300]
                                    : darkMode
                                        ? Colors.red.withOpacity(0.8)
                                        : Colors.red[400]
                                : Colors.grey,
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '${busSelectProvider.velocidad} km/h',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              MarkerLayer(
                markers: <Marker>[
                  Marker(
                    rotate: true,
                    height: 60,
                    width: 60,
                    point: markerBusInitial,
                    child: GestureDetector(
                      onTap: () {
                        if (!isSelectedMarkerBus) {
                          sheetController.animateTo(
                            0.5,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.linear,
                          );
                        } else {
                          sheetController.animateTo(
                            0.0, // Cambiar a cerrar el sheet, si es lo deseado
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear,
                          );
                        }

                        // Actualizar el estado
                        setState(() {
                          selectedMarkerIndex = -1;
                          isSelectedMarkerBus = !isSelectedMarkerBus;
                        });
                      },
                      child: MarkerBus(_animationController),
                    ),
                  )
                ],
              ),
            ],
          ),
          _buildZoomButtons(),
          DraggableScrollableSheet(
            initialChildSize: 0.0,
            minChildSize: 0.0,
            maxChildSize: 1.0,
            // snap: true,
            controller: sheetController,
            snapSizes: [
              // 0.35,
              // 0.5,
              // 1.0
              // 1.0,
            ],
            shouldCloseOnMinExtent: false,
            // snap: false,
            builder: (BuildContext context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  // color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SliverList.list(children: [
                      Text(
                        'Detalles del GPS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 7),
                      // Velocidad
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Velocidad:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                selectedMarkerIndex != -1
                                    ? '${busRecordProvider[selectedMarkerIndex].velocidad} km/h'
                                    : '${busSelectProvider.velocidad} km/h', // Valor simulado
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: busSelectProvider.acc == 1
                                      ? Colors.greenAccent
                                      : Colors.red,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.white30),
                      SizedBox(height: 7),
                      // Kilómetros recorridos
                      busSelectProvider.codigoInterno != null
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Padron',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'PD ${busSelectProvider.codigoInterno} ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.white30),
                                SizedBox(height: 8),
                              ],
                            )
                          : SizedBox(),
                      // Dirección
                      Text(
                        'Dirección:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        selectedMarkerIndex != -1
                            ? (busRecordProvider[selectedMarkerIndex]
                                    .direccionTramaActual ??
                                'Dirección no disponible')
                            : (busSelectProvider.direccionTramaActual ??
                                'Dirección no disponible'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Divider(color: Colors.white30),
                      SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kilometros Acumulados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            selectedMarkerIndex != -1
                                ? '${(busRecordProvider[selectedMarkerIndex].kilometrajeAcum).toStringAsFixed(2)}'
                                : '${(busSelectProvider.kilometrajeAcum).toStringAsFixed(2)}', // Valor simulado
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Galones Consumidos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            selectedMarkerIndex != -1
                                ? '${(busRecordProvider[selectedMarkerIndex].kilometrajeAcum / busSelectProvider.kmgalon).toStringAsFixed(2)}'
                                : '${(busSelectProvider.kilometrajeAcum / busSelectProvider.kmgalon).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white30),
                      SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'IMEI',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${busSelectProvider.imeil}', // Valor simulado
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white30),
                      SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SIM',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${busSelectProvider.sim}', // Valor simulado
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.white30),
                      SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha Trama',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            selectedMarkerIndex != -1
                                ? '${busRecordProvider[selectedMarkerIndex].fechaTramaActual}'
                                : '${busSelectProvider.fechaTramaActual != null ? busSelectProvider.fechaTramaActual : 'Fecha no encontrada'}', // Valor simulado
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white30),

                      busSelectProvider.imagenConductor.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Conductor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Stack(
                                                children: [
                                                  InteractiveViewer(
                                                    child: Image.network(
                                                      busSelectProvider
                                                          .imagenConductor,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.black,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Cierra el diálogo
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                            busSelectProvider.imagenConductor),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      busSelectProvider.nombreConductor,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: () {
                          sheetController.animateTo(
                            0.0, // Cambiar a cerrar el sheet, si es lo deseado
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear,
                          );
                        },
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ])
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButtons() {
    return Positioned(
      right: 10,
      top: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoundButton(
            onPressed: zoomIn,
            icon: Icons.zoom_in,
          ),
          const SizedBox(height: 10),
          _buildRoundButton(
            onPressed: zoomOut,
            icon: Icons.zoom_out,
          ),
          const SizedBox(height: 10),
          _buildRoundButton(
            onPressed: () {
              setState(() {
                if (isFocusBus == true) {
                  return;
                }
                isFocusBus = !isFocusBus;
              });
            },
            icon:
                isFocusBus ? Icons.directions_walk_outlined : Icons.my_location,
          ),
          const SizedBox(height: 10),
          _buildRoundButton(
            onPressed: () {
              context.pop(1);
            },
            icon: Icons.home_filled,
          ),
        ],
      ),
    );
  }

  Widget _buildPolylineLayer(List<LatLng> points) {
    return Stack(
      children: [
        // Polyline
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: _mapController.camera.zoom > 18.0 ? 1.0 : 4.0,
              strokeCap: StrokeCap.square,
              strokeJoin: StrokeJoin.miter,
              useStrokeWidthInMeter: true,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

// Función para calcular el ángulo de la flecha
  double _getArrowAngle(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    // Calcula el ángulo entre la última y la penúltima coordenada
    LatLng start = points[points.length - 2];
    LatLng end = points.last;

    double deltaX = end.longitude - start.longitude;
    double deltaY = end.latitude - start.latitude;

    return atan2(deltaY, deltaX); // Utiliza atan2 para calcular el ángulo
  }

  Widget _darkModeContainerIfEnabled(Widget child) {
    if (!darkMode) return child;

    return _darkModeTileBuilder(context, child);
  }

  Widget _darkModeTileBuilder(
    BuildContext context,
    Widget tileWidget,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
        0, 0, 0, 1, 0, // Alpha channel
      ]),
      child: tileWidget,
    );
  }

  Widget _buildRoundButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Color(0Xff4737FF),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
