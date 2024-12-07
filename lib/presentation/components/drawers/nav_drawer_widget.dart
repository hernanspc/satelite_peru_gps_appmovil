import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';
import 'package:satelite_peru_gps/data/services/mqtt_service.dart';
import 'package:satelite_peru_gps/presentation/components/drawers/drawer_event.dart';
import 'package:satelite_peru_gps/presentation/components/drawers/nav_drawer_bloc.dart';
import 'package:satelite_peru_gps/presentation/components/drawers/nav_drawer_state.dart';

class _NavigationItem {
  final NavItem item;
  final String title;
  final IconData icon;

  _NavigationItem(this.item, this.title, this.icon);
}

class NavDrawerWidget extends StatelessWidget {
  NavDrawerWidget({super.key});

  final List<_NavigationItem> _listItems = [
    _NavigationItem(
      NavItem.homeView,
      "Inicio",
      IconlyBold.home,
    ),
    _NavigationItem(
      NavItem.profileView,
      "Profile",
      IconlyBold.profile,
    ),
    _NavigationItem(
      NavItem.orderView,
      "Orders",
      IconlyBold.category,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userSession = authService.userSession;

    return Drawer(
      child: Column(
        children: [
          /// Header
          UserAccountsDrawerHeader(
            accountName: Text(
              userSession?.name ?? '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              userSession?.email ?? '',
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://blog.sebastiano.dev/content/images/2019/07/1_l3wujEgEKOecwVzf_dqVrQ.jpeg',
                ),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://avatars.githubusercontent.com/u/91388754?v=4',
              ),
            ),
          ),

          // Lista de elementos existentes
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _listItems.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) =>
                  BlocBuilder<NavDrawerBloc, NavDrawerState>(
                builder: (BuildContext context, NavDrawerState state) =>
                    _buildItem(_listItems[index], state),
              ),
            ),
          ),

          // Elemento "Cerrar sesión"
          _buildItem(
            _NavigationItem(
              NavItem.logout,
              "Cerrar sesión",
              IconlyBold.logout,
            ),
            const NavDrawerState(
              NavItem.logout,
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildItem(_NavigationItem data, NavDrawerState state) =>
      _makeListItem(data, state);

  Widget _makeListItem(_NavigationItem data, NavDrawerState state) => Card(
        color: Colors.grey[100],
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        borderOnForeground: true,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Builder(
          builder: (BuildContext context) => ListTile(
            title: Text(
              data.title,
              style: TextStyle(
                fontWeight: data.item == state.selectedItem
                    ? FontWeight.bold
                    : FontWeight.w300,
                color: data.item == state.selectedItem
                    ? const Color.fromARGB(255, 112, 119, 249)
                    : Colors.grey[600],
              ),
            ),
            leading: Icon(
              data.icon,
              color: data.item == state.selectedItem
                  ? const Color.fromARGB(255, 112, 119, 249)
                  : Colors.grey[600],
            ),
            onTap: () => _handleItemClick(context, data.item),
          ),
        ),
      );

  void _handleItemClick(BuildContext context, NavItem item) {
    if (item == NavItem.logout) {
      _showLogoutConfirmationDialog(context);
    } else {
      BlocProvider.of<NavDrawerBloc>(context).add(NavigateTo(item));
      // Navega a la ruta específica según el item seleccionado.
      switch (item) {
        case NavItem.homeView:
          context.go('/home_screen');
          break;
        case NavItem.profileView:
          context.go('/detail_screen');
          break;
        case NavItem.orderView:
          context.go('/orders_screen');
          break;
        case NavItem.cartView:
          context.go('/detail_screen');
          break;
        case NavItem.logout:
          return;
        // TODO: Handle this case.
      }

      // Solo cierra el drawer si la navegación fue exitosa.
      if (Navigator.canPop(context)) {
        context.pop();
      }
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Realmente desea cerrar sesión?'),
          actions: <Widget>[
            PlatformDialogAction(
              child: PlatformText('Cancelar'),
              onPressed: () {
                context.pop();
              },
            ),
            PlatformDialogAction(
              child: PlatformText(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                context.pop();
                AuthService.deleteToken();
                context.go('/login_screen');

                MqttService().unsubscribe('25/141');

                MqttService().dispose();
              },
            ),
          ],
        );
      },
    );
  }
}
