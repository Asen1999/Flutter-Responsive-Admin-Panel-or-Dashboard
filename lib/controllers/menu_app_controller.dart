import 'package:flutter/material.dart';

enum AppMenuPage {
  dashboard,
  imageCreate,
  historyImageList,
}

class MenuNavItem {
  const MenuNavItem({
    required this.title,
    required this.svgSrc,
    required this.page,
  });

  final String title;
  final String svgSrc;
  final AppMenuPage page;
}

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppMenuPage _currentPage = AppMenuPage.dashboard;

  final List<MenuNavItem> _menuItems = const <MenuNavItem>[
    MenuNavItem(
      title: "Dashboard",
      svgSrc: "assets/icons/menu_dashboard.svg",
      page: AppMenuPage.dashboard,
    ),
    MenuNavItem(
      title: "Image Create",
      svgSrc: "assets/icons/menu_store.svg",
      page: AppMenuPage.imageCreate,
    ),
    MenuNavItem(
      title: "History Image List",
      svgSrc: "assets/icons/menu_doc.svg",
      page: AppMenuPage.historyImageList,
    ),
  ];

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  AppMenuPage get currentPage => _currentPage;
  List<MenuNavItem> get menuItems => List<MenuNavItem>.unmodifiable(_menuItems);

  void setPage(AppMenuPage page) {
    if (_currentPage == page) {
      return;
    }
    _currentPage = page;
    notifyListeners();
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
