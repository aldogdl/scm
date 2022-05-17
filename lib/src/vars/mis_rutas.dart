import 'package:flutter/material.dart' show MaterialPage, Widget, RouteSettings;
import 'package:routemaster/routemaster.dart';
import 'package:scm/src/pages/reload_home.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';

enum Rname { login, home, reload, clean }

class MyRutas {

  ///
  static final withOutLogin = RouteMap(

    onUnknownRoute: (route) => const Redirect('/'),
    routes: {
      '/': (_) => _page(const ReloadHome()),
      '/login': (_) => _page(const LoginPage()),
    },
  );

  ///
  static RouteMap withLogin() {

    Map<String, RouteSettings Function(RouteData)> rutas = {};

    _paths.map((rta){
      return rutas.putIfAbsent(rta['path'], () => (_) => _page(rta['child']));
    }).toList();
    return RouteMap(routes: rutas);
  }

  ///
  static const Map<Rname, String> _pathStr = {
    Rname.clean : '/',
    Rname.home : '/home',
    Rname.login : '/login',
    Rname.reload  : '/reload',
  };

  ///
  static final List<Map<String, dynamic>> _paths = [
    {'path': '${_pathStr[Rname.clean]}', 'child': const ReloadHome()},
    {'path': '${_pathStr[Rname.home]}', 'child': const HomePage()},
    {'path': '${_pathStr[Rname.login]}', 'child': const LoginPage()},
    {'path': '${_pathStr[Rname.reload]}', 'child': const ReloadHome()},
  ];

  ///
  static String getRut(Rname ruta) {

    if(_pathStr.containsKey(ruta)) {
      return _pathStr[ruta]!;
    }
    return '/';
  }

  ///
  static MaterialPage _page(Widget child) => MaterialPage(child: child);
}