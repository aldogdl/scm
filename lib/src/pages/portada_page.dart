import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'layout_page.dart';
import 'login_page.dart';
import 'puppe_conn/connect_view.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
import '../services/puppetter/vars_puppe.dart';
import '../services/puppetter/browser_conn.dart';
import '../services/puppetter/repository/puppe_repository.dart';
import '../services/puppetter/providers/browser_provider.dart';
import '../widgets/texto.dart';

class PortadaPage extends StatefulWidget {
  
  const PortadaPage({Key? key}) : super(key: key);

  @override
  State<PortadaPage> createState() => _PortadaPageState();
}

class _PortadaPageState extends State<PortadaPage> {

  
  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocketConn>().isShowConfig = false;
      context.read<ProcessProvider>().isTest = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutPage(
      child: Container(
        constraints: BoxConstraints.expand(
          height: appWindow.size.height - 55
        ),
        child: _body(context)
      )
    );
  }

  ///
  Widget _body(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Image(
            image: AssetImage('assets/logo_dark.png'),
          ),
        ),
        const Texto(
          txt: 'SCM',
          txtC: Color.fromARGB(255, 61, 54, 54),
          sz: 90, isCenter: true, isBold: true,
        ),
        const Texto(txt: 'SERVIDOR CENTRAL DE MENSAJERÍA', txtC: Colors.green),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Texto(
            txt: 'Por el momento no hay nada por ser enviado '
            'estoy a la espera de cualquier solicitud.',
            isCenter: true,
          )
        ),
        const SizedBox(height: 20),
        Selector<BrowserProvider, bool>(
          selector: (_, prov) => prov.isOk,
          builder: (_, val, child) {
            return (val) ? child! : _checkConn(context);
          },
          child: _procesos(context)
        ),
      ],
    );
  }

  ///
  Widget _checkConn(BuildContext context) {

    final conn = context.read<BrowserProvider>();

    return StreamBuilder<String>(
      stream: _checkConnBrowser(context, conn),
      initialData: 'Revisando Browser',
      builder: (_, AsyncSnapshot str) {

        return Texto(
          txt: str.data,
          txtC: Colors.amber,
          isCenter: true, sz: 13,
        );
      }
    );
  }

  ///
  Widget _procesos(BuildContext context) {

    return Selector<ProcessProvider, String>(
      selector: (_, prov) => prov.reloadMsgAcction,
      builder: (_, str, __) {

        Future.delayed(const Duration(milliseconds: 200), () {
          _deternimarAccion(context, str);
        });

        return Texto(
          txt: str,
          txtC: Colors.amber,
          isCenter: true, sz: 13,
        );
      }
    );
  }

  ///
  Stream<String> _checkConnBrowser(BuildContext context, BrowserProvider connProv) async* {

    final pupEm = PuppeRepository();

    bool launchBrowser = true;
    bool existWhast = false;
    bool tryConn = false;
    bool searchWats = false;
    bool closeBrowser = false;

    yield 'Recuperando Metadatos Browser';
    final metadata = await pupEm.getListTargets();

    // Solo probamos la coneccion sis sigue activa con los valores actuales
    if(connProv.browser == null) {
      tryConn = true;
    }else{
      if(!connProv.browser!.isConnected) {
        if(metadata.isEmpty) {
          closeBrowser = true;
        }else{
          tryConn = true;
        }
      }else{
        searchWats = true;
        launchBrowser = false;
      }
    }

    yield 'Revisando conexión con Browser';
    if(tryConn) {
      if(!closeBrowser) {
        connProv.browser = await BrowserConn.tryConnect();
        if(connProv.browser != null) {
          launchBrowser = false;
          searchWats = true;
        }
      }
    }

    yield 'Buscando Mensajería';
    if(searchWats) {
      if(metadata.isNotEmpty) {
        // Existe una instancia del browser
        final hasWs = metadata.where(
          (e) => e['url'].toString().toLowerCase() == uriWhatsapp.toLowerCase()
        );
        if(hasWs.isNotEmpty) {
          connProv.targetId = '${hasWs.first['id']}';
          if(connProv.pagewa == null) {
            connProv.pagewa = await BrowserConn.getPageByIdTarget(
              connProv.browser!, connProv.targetId
            );
            if(connProv.pagewa != null) {
              existWhast = true;
            }
          }else{
            existWhast = true;
          }
        }
      }
    }

    yield 'Probando conexión con Browser';

    if(existWhast) {
      pupEm.getFrontTarget(connProv.targetId);
      connProv.titleCurrent = pageWhatsapp;
      String check = await BrowserConn.checarConectividad(
        connProv.browser, connProv.pagewa, connProv.titleCurrent
      );
      if(check.isEmpty) {
        yield 'Conexión Browser Exitosa';
        Future.delayed(const Duration(milliseconds: 1000), (){
          connProv.isOk = true;
        });
        return;
      }
    }

    int laPage = 0;
    if(!launchBrowser && !existWhast) {
      laPage = 1;
    }

    yield 'Redireccionando...';
    Future.delayed(const Duration(milliseconds: 1000), (){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConnectView(
            page: laPage,
            onClose: (_) => setState(() { }),
          )
        )
      );
    });

  }

  ///
  Future<void> _deternimarAccion(BuildContext context, String accion) async {

    final proc = context.read<ProcessProvider>();
    
    if(!context.read<SocketConn>().isLoged) {
      _login(context);
    }

    if(accion.toLowerCase().contains('iniciando')) {
      homePage(context);
      return;
    }

    if(accion.toLowerCase().contains('espera')) {
      final nav = Navigator.of(context);
      if(nav.canPop()) {
        proc.cleanCampaingCurrent();
        nav.pop();
      }
      return;
    }
  }

  ///
  void _login(BuildContext context) {

    context.read<ProcessProvider>().cleanReloadMsgAcction();
    MaterialPageRoute(
      builder: (_) => const LoginPage()
    );
  }

  ///
  void homePage(BuildContext context) {
    
    context.read<ProcessProvider>().setReloadMsgAcction('Iniciando Envio');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomePage()
      )
    );
  }
}