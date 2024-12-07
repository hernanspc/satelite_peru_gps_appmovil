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
      // pageBuilder: (context, state) {
      //   return CustomTransitionPage(
      //     // transitionDuration: Duration(seconds: 1),
      //     fullscreenDialog: true,
      //     key: state.pageKey,
      //     child: HomeScreen(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(
      //         opacity: animation,
      //         // opacity: CurveTween(curve: Curves.linear).animate(animation),
      //         child: child,
      //       );
      //     },
      //   );
      // },
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
    // GoRoute(
    //   path: '/register_person',
    //   builder: (context, state) {
    //     final filter1 = state.uri.queryParameters['filter1'];
    //     final filter2 = state.uri.queryParameters['filter2'];

    //     return RegisterPerson(
    //       filter1: filter1 ?? '',
    //       filter2: filter2 ?? '',
    //     );
    //   },
    // ),
  ],
);
