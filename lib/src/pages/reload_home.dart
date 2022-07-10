import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'layout_page.dart';
import 'login_page.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
import '../widgets/texto.dart';

class ReloadHome extends StatelessWidget {
  
  const ReloadHome({Key? key}) : super(key: key);

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
        Icon(
          Icons.sentiment_satisfied_alt,
          size: 150,
          color: Colors.green.withOpacity(0.3)
        ),
        const SizedBox(height: 10),
        Selector<ProcessProvider, String>(
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
        ),
      ],
    );
  }

  ///
  Future<void> _deternimarAccion(BuildContext context, String accion) async {

    final proc = context.read<ProcessProvider>();
    
    if(accion.isEmpty){
      if(proc.isStopAllCrones) {
        proc.startAllCrones();
      }
      return;
    }

    if(!context.read<SocketConn>().isLoged) {
      _login(context);
    }
    if(accion.toLowerCase().contains('iniciando')) {
      homePage(context);
      return;
    }
    if(accion.toLowerCase().contains('campaña')) {
      final nav = Navigator.of(context);
      if(nav.canPop()) {
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