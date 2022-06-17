import 'package:flutter/material.dart' show BuildContext;
import 'package:go_router/go_router.dart';

import '../pages/reload_home.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

enum Rname { login, home, reload, clean }

class MyRutas {

  ///
  static const Map<Rname, String> _pathStr = {
    Rname.clean : '/',
    Rname.home : '/home',
    Rname.login : '/login',
    Rname.reload  : '/reload',
  };

  ///
  static GoRouter get() {

    return GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: _pathStr[Rname.clean]!,
          name: Rname.clean.name,
          builder: (BuildContext context, GoRouterState state) => const ReloadHome(),
        ),
        GoRoute(
          path: _pathStr[Rname.home]!,
          name: Rname.home.name,
          builder: (BuildContext context, GoRouterState state) => const HomePage(),
        ),
        GoRoute(
          path: _pathStr[Rname.login]!,
          name: Rname.login.name,
          builder: (BuildContext context, GoRouterState state) => const LoginPage(),
        ),
        GoRoute(
          path: _pathStr[Rname.reload]!,
          name: Rname.reload.name,
          builder: (BuildContext context, GoRouterState state) => const ReloadHome(),
        ),
      ],
    );
  }


}