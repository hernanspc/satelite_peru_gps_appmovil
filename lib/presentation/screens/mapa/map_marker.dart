import 'package:latlong2/latlong.dart';

class MapMarker {
  const MapMarker({
    required this.image,
    required this.title,
    required this.address,
    required this.location,
  });
  final String image;
  final String title;
  final String address;
  final LatLng location;
}

final _locations = [
  LatLng(-12.046373, -77.042754), // Plaza Mayor de Lima
  LatLng(-12.093092, -77.046850), // Parque Kennedy
  LatLng(-12.075620, -77.022049), // Museo Larco
  LatLng(-12.121900, -77.029701), // Circuito Mágico del Agua
  LatLng(-12.076247, -77.087485), // Parque de las Leyendas
  LatLng(-12.041484, -77.043903), // Barrio Chino
  LatLng(-12.044930, -77.030889), // Plaza San Martín
  LatLng(-12.092344, -77.034003), // Huaca Pucllana
];

List<LatLng> locationsRoute = [
  LatLng(-11.97454, -76.91882),
  LatLng(-11.97463, -76.91882),
  LatLng(-11.97494, -76.91879),
  LatLng(-11.97497, -76.91878),
  LatLng(-11.97498, -76.91875),
  LatLng(-11.97559, -76.91872),
  LatLng(-11.97559, -76.91872),
  LatLng(-11.97555, -76.91818),
  LatLng(-11.97555, -76.91758),
  LatLng(-11.97551, -76.91703),
  LatLng(-11.97551, -76.91703),
  LatLng(-11.97668, -76.91692),
  LatLng(-11.97788, -76.91682),
  LatLng(-11.97788, -76.91682),
  LatLng(-11.97855, -76.9166),
  LatLng(-11.97995, -76.91604),
  LatLng(-11.98024, -76.91593),
  LatLng(-11.98144, -76.91547),
  LatLng(-11.98144, -76.91547),
  LatLng(-11.98131, -76.91511),
  LatLng(-11.98129, -76.91504),
  LatLng(-11.98129, -76.91504),
];


const _path = 'assets/images/';

final mapMarkers = [
  MapMarker(
    image: '${_path}helpImage.png',
    title: 'Plaza Mayor de Lima',
    address: 'Centro de Lima',
    location: _locations[0],
  ),
  MapMarker(
    image: '${_path}supportIcon.png',
    title: 'Parque Kennedy',
    address: 'Miraflores',
    location: _locations[1],
  ),
  MapMarker(
    image: '${_path}userImage.png',
    title: 'Museo Larco',
    address: 'Pueblo Libre',
    location: _locations[2],
  ),
  MapMarker(
    image: '${_path}helpImage.png',
    title: 'Circuito Mágico del Agua',
    address: 'Cercado de Lima',
    location: _locations[3],
  ),
  MapMarker(
    image: '${_path}supportIcon.png',
    title: 'Parque de las Leyendas',
    address: 'San Miguel',
    location: _locations[4],
  ),
  MapMarker(
    image: '${_path}userImage.png',
    title: 'Barrio Chino',
    address: 'Centro de Lima',
    location: _locations[5],
  ),
  MapMarker(
    image: '${_path}supportIcon.png',
    title: 'Plaza San Martín',
    address: 'Centro de Lima',
    location: _locations[6],
  ),
  MapMarker(
    image: '${_path}helpImage.png',
    title: 'Huaca Pucllana',
    address: 'Miraflores',
    location: _locations[7],
  ),
];
