import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';

class LoadingScreen extends StatelessWidget {
  static const nameScreen = "loading_screen";

  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff252829),
      body: FutureBuilder(
        future: _navigateAfterDelay(context),
        builder: (context, snapshot) {
          return Center(
            child: ZoomOut(
              from: 10,
              duration: Duration(seconds: 2),
              child: Image.asset(
                'assets/icon/sp.png',
                width: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateAfterDelay(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    await checkLoginState(context);
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final autenticado = await authService.isLoggedIn();
    if (autenticado) {
      return context.go('/home_screen');
    } else {
      return context.go('/login_screen');
    }
  }
}
