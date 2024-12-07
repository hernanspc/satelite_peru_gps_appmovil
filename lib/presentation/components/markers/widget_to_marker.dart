import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:satelite_peru_gps/presentation/components/markers/start_marker.dart';

// Future<Uint8List> getStartCustomMarkerBytes(
Future<BitmapDescriptor> getStartCustomMarker(
    String minutes, String destination) async {
  final recorder = ui.PictureRecorder();

  final canvas = ui.Canvas(recorder);
  const size = ui.Size(350, 150);

  final startMarker = StartMarkerPainter(
    minutes: minutes,
    destination: destination,
  );

  startMarker.paint(canvas, size);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  // return byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
