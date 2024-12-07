import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // Puede ser String o Widget
  final Widget? leading; // Widget opcional para el leading
  final List<Widget>? actions; // Lista de widgets para el lado derecho

  const CustomAppBar({Key? key, this.title, this.leading, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0Xff4737FF),
      foregroundColor: Colors.white,
      leading: leading, // Usa el widget leading si está proporcionado
      title: _buildTitle(title),
      actions: actions, // Usa la lista de widgets para el lado derecho
    );
  }

  Widget _buildTitle(dynamic title) {
    if (title is String) {
      return Text(
        title,
        style: TextStyle(
          fontSize: 17,
        ),
      );
    } else if (title is Widget) {
      return title;
    } else {
      return Text(
          'Default Title'); // Título predeterminado en caso de que no sea String ni Widget
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
