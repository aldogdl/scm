import 'package:flutter/material.dart' show BuildContext;
import 'package:go_router/go_router.dart';

import '../pages/reload_home.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

enum Rname { login, home, reload, clean }

class MyRutas {

  ///
  static const Map<Rname, String> pathStr = {
    Rname.clean : '/',
    Rname.home : '/home',
    Rname.login : '/login',
    Rname.reload  : '/reload',
  };

  ///
  static GoRouter get() {

    return GoRouter(
      initialLocation: pathStr[Rname.clean]!,
      routes: <GoRoute>[
        GoRoute(
          path: pathStr[Rname.clean]!,
          name: Rname.clean.name,
          builder: (BuildContext context, GoRouterState state) => const ReloadHome(),
        ),
        GoRoute(
          path: pathStr[Rname.home]!,
          name: Rname.home.name,
          builder: (BuildContext context, GoRouterState state) => const HomePage(),
        ),
        GoRoute(
          path: pathStr[Rname.login]!,
          name: Rname.login.name,
          builder: (BuildContext context, GoRouterState state) => const LoginPage(),
        ),
        GoRoute(
          path: pathStr[Rname.reload]!,
          name: Rname.reload.name,
          builder: (BuildContext context, GoRouterState state) => const ReloadHome(),
        ),
      ],
    );
  }


}