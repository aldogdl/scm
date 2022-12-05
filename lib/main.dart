import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scm/src/pages/home_page.dart';

import 'src/config/sng_manager.dart';
import 'src/pages/login_page.dart';
import 'src/providers/process_provider.dart';
import 'src/providers/socket_conn.dart';
import 'src/providers/terminal_provider.dart';
import 'src/services/puppetter/providers/browser_provider.dart';
import 'src/services/get_paths.dart';
import 'src/vars/globals.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  sngManager();
  final globals = getSngOf<Globals>();
  Size wsize = WidgetsBinding.instance.window.physicalSize;

  doWhenWindowReady(() async {
    
    if(globals.sizeWin.width == 0) {
      globals.sizeWin = await GetPaths.screen(set: '${wsize.width} ${wsize.height}');
    }else{
      globals.sizeWin = await GetPaths.screen();
    }
    var w = globals.sizeWin.width * 0.27;
    appWindow.minSize = const Size(360, 750.0);
    appWindow.maxSize = Size(w, globals.sizeWin.height);
    appWindow.alignment = Alignment.topLeft;
    appWindow.maximize();
    appWindow.show();
  });
  
  runApp(const ProvidersConfig());
}

class ProvidersConfig extends StatelessWidget {

  const ProvidersConfig({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketConn>(create: (_) => SocketConn()),
        ChangeNotifierProvider<ProcessProvider>(create: (_) => ProcessProvider()),
        ChangeNotifierProvider<BrowserProvider>(create: (_) => BrowserProvider()),
        ChangeNotifierProvider<TerminalProvider>(create: (_) => TerminalProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final routerKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      title: 'SCM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.black.withOpacity(0.5)),
          trackBorderColor: MaterialStateProperty.all(Colors.black.withOpacity(0))
        )
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [ Locale('es', 'ES') ],
      navigatorKey: routerKey,
      home: const BuildContextGral(),
    );
  }
}

class BuildContextGral extends StatelessWidget {

  const BuildContextGral({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (ctxTwo) {

            return Selector<SocketConn, bool>(
              selector: (_, prov) => prov.isLoged,
              builder: (_, isLog, __) {
                return (isLog)
                  ? const HomePage()
                  : const LoginPage();
              },
            );
          }
        )
      ],
    );
  }
}
