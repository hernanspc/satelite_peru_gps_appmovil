import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:satelite_peru_gps/app_theme.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:satelite_peru_gps/presentation/components/app_bar/CustomAppBar.dart';
import 'package:satelite_peru_gps/presentation/screens/reports/day_picker_page.dart';
import 'package:satelite_peru_gps/presentation/screens/reports/month_picker_page.dart';
import 'package:satelite_peru_gps/presentation/screens/reports/week_picker_page.dart';

class BusReportScreen extends StatefulWidget {
  const BusReportScreen({super.key});

  @override
  State<BusReportScreen> createState() => _BusReportScreenState();
}

class _BusReportScreenState extends State<BusReportScreen> {
  int _selectedTab = 0;

  CarsService carsService = CarsService();
  List<Map<String, dynamic>> reportData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final GoRouterState state = GoRouterState.of(context);
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    final String placa = extra['placa'] as String;

    final screens = [DayPickerPage(), WeekPickerPage(), MonthPickerPage()];
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reporte Bus $placa',
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Icons.settings),
        //   ),
        // ],
      ),
      backgroundColor:
          isLightMode == true ? AppTheme.white : const Color(0xff18191A),
      body: IndexedStack(
        index: _selectedTab,
        children: screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: const Color(0xff6456FF).withOpacity(0.4),
            textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: TextStyle(color: Colors.white.withOpacity(0.5)))),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.date_range),
              activeIcon: Icon(Icons.date_range_outlined),
              label: "Dia",
              // backgroundColor: colors.primary,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.date_range), label: "Semanal"),
            BottomNavigationBarItem(
                icon: Icon(Icons.date_range), label: "Mensual"),
          ],
          fixedColor: const Color(0xff6456FF),
          currentIndex: _selectedTab,
          onTap: (newIndex) {
            setState(() {
              _selectedTab = newIndex;
            });
          },
        ),
      ),
    );
  }
}
