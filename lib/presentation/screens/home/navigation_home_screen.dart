import 'package:satelite_peru_gps/app_theme.dart';
import 'package:satelite_peru_gps/presentation/custom_drawer/drawer_user_controller.dart';
import 'package:satelite_peru_gps/presentation/custom_drawer/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:satelite_peru_gps/presentation/screens/history/history_screen.dart';
import 'package:satelite_peru_gps/presentation/screens/home/home_screen.dart';
import 'package:satelite_peru_gps/presentation/screens/about/AboutScreen.dart';

import 'package:satelite_peru_gps/presentation/screens/home/invite_friend_screen.dart';
import 'package:satelite_peru_gps/presentation/screens/reports/ReportsScreen.dart';

class NavigationHomeScreen extends StatefulWidget {
  static const nameScreen = "home_screen";

  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          setState(() {
            screenView = const MyHomePage();
          });
          break;
        case DrawerIndex.Help:
          setState(() {
            screenView = HistoryScreen();
          });
          break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = ReportsScreen();
          });
          break;
        case DrawerIndex.Invite:
          setState(() {
            screenView = InviteFriend();
          });
          break;
        default:
          break;
      }
    }
  }
}
