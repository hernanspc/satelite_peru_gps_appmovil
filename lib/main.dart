import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:satelite_peru_gps/data/config/router/router.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:satelite_peru_gps/data/services/mqtt_service.dart';
import 'package:satelite_peru_gps/data/services/reports_service.dart';
import 'package:satelite_peru_gps/presentation/components/drawers/nav_drawer_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        //Auth Login
        ChangeNotifierProvider(create: (context) => AuthService()),
        //CarsService
        ChangeNotifierProvider(create: (context) => CarsService()),
        //ReportsService
        ChangeNotifierProvider(create: (context) => ReportsService()),
        //Bloc para drawer
        BlocProvider(create: (context) => NavDrawerBloc()),
        ChangeNotifierProvider(
            create: (context) => MqttService()..connect(context)),
      ],
      child: MyApp(),
    ),
  );
}

// void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.ubuntu().fontFamily,
        colorScheme: ColorScheme.fromSwatch(
          // primarySwatch: Colors.purple,
          accentColor: Colors.orange, // Aquí defines el color secundario
          // backgroundColor: Colors.white,
        ),
        // textSelectionTheme: TextSelectionThemeData(
        //   selectionColor: Colors.red[200],
        //   cursorColor: Colors.pink[300],
        // ),
      ),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Agregar esto
      ],
      supportedLocales: [
        const Locale('es', 'ES'),
      ],
      routerConfig: appRouter,
    );
  }
}
