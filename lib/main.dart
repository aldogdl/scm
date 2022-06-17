import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/services/puppetter/providers/browser_provider.dart';
import 'src/providers/process_provider.dart';
import 'src/providers/socket_conn.dart';
import 'src/config/sng_manager.dart';
import 'src/vars/mis_rutas.dart';

void main() async {

  sngManager();
  WidgetsFlutterBinding.ensureInitialized();
  
  doWhenWindowReady(() {
    appWindow.minSize = const Size(360.0, 750.0);
    appWindow.maxSize = const Size(360.0, 768.0);
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
        ChangeNotifierProvider<SocketConn>(create: (context) => SocketConn()),
        ChangeNotifierProvider<ProcessProvider>(create: (context) => ProcessProvider()),
        ChangeNotifierProvider<BrowserProvider>(create: (context) => BrowserProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final router = MyRutas.get();

    return MaterialApp.router(
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
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
