import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:satelite_peru_gps/presentation/screens/home/BusMapView.dart';

class MarkerBus extends AnimatedWidget {
  const MarkerBus(Animation<double> animation, {Key? key})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final newValue = lerpDouble(0.5, 1.0, value)!;
    const size = 50.0;

    return Center(
      child: Stack(
        children: [
          Center(
            child: Container(
              height: size * newValue,
              width: size * newValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MARKER_COLOR.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: Container(
              child: Image.asset(
                'assets/app/autobus.png',
                width: 20.0,
                height: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
