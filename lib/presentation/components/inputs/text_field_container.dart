import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: isLightMode
            ? Colors.red[50]
            : Colors.grey[900], // Fondo más oscuro en dark mode
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
