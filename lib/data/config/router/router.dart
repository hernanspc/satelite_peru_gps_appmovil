import 'package:go_router/go_router.dart';
import 'package:satelite_peru_gps/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/loading_screen',
  routes: [
    //AUTH
    GoRoute(
      path: '/loading_screen',
      name: LoadingScreen.nameScreen,
      builder: (context, state) => LoadingScreen(),
    ),
    GoRoute(
      path: '/login_screen',
      name: LoginScreen.nameScreen,
      builder: (context, state) => LoginScreen(),
    ),
    //APP
    GoRoute(
      path: '/home_screen',
      name: NavigationHomeScreen.nameScreen,
      builder: (context, state) => NavigationHomeScreen(),
    ),
    GoRoute(
      path: '/bus_map_view_screen',
      builder: (context, state) => BusMapView(),
    ),
    GoRoute(
      path: '/bus_report_screen',
      builder: (context, state) => BusReportScreen(),
    ),
    GoRoute(
      path: '/bus_map_historial',
      builder: (context, state) => BusMapHistorial(),
    )
  ],
);
