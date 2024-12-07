import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension BitmapDescriptorExt on BitmapDescriptor {
  ImageProvider toImageProvider() {
    return MemoryImage(toBytes());
  }

  Uint8List toBytes() {
    // Aquí debemos implementar cómo obtener los bytes de BitmapDescriptor.
    // Esto depende de cómo obtienes el descriptor en tu caso particular.
    // La siguiente línea es un placeholder y debe ser reemplazada con la lógica correcta.
    throw UnimplementedError('Implement the conversion to bytes');
  }
}
