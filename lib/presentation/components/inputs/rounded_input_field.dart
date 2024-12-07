import 'package:flutter/material.dart';
import 'package:satelite_peru_gps/presentation/components/inputs/text_field_container.dart';

class RoundedInputField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final ValueChanged<String> onChange;
  final TextEditingController controller;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.onChange,
    this.isPassword = false,
    required this.controller,
  }) : super(key: key);

  @override
  _RoundedInputFieldState createState() => _RoundedInputFieldState();
}

class _RoundedInputFieldState extends State<RoundedInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    return TextFieldContainer(
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChange,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: TextInputType.text,
        style: TextStyle(
            color: isLightMode ? Colors.black : Colors.white), // Texto
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
              color:
                  isLightMode ? Colors.black54 : Colors.white54), // Hint text
          icon: Icon(widget.icon,
              color: isLightMode ? Color(0xff898989) : Colors.white70), // Ícono
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: isLightMode
                        ? Colors.grey
                        : Colors.white70, // Ícono del password
                  ),
                )
              : null,
          border: InputBorder.none,
          fillColor: isLightMode
              ? Colors.red[50]
              : Colors.grey[900], // Color de fondo del input
          filled: true,
        ),
      ),
    );
  }
}
