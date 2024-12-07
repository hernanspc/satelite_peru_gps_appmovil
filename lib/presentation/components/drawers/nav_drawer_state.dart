import 'package:equatable/equatable.dart';

enum NavItem {
  homeView,
  profileView,
  orderView,
  cartView,
  logout,
}

class NavDrawerState extends Equatable {
  final NavItem selectedItem;

  const NavDrawerState(this.selectedItem);

  @override
  List<Object?> get props => [
        selectedItem,
      ];
}
