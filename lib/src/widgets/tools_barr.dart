
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/pages/login_page.dart';

import '../config/sng_manager.dart';
import '../pages/puppe_conn/connect_view.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
import '../providers/terminal_provider.dart';
import '../services/puppetter/providers/browser_provider.dart';
import '../vars/globals.dart';
import '../widgets/my_tool_tip.dart';
import '../widgets/texto.dart';

class ToolsBarr extends StatelessWidget {

  final ValueChanged<String> onTap;
  ToolsBarr({
    Key? key,
    required this.onTap
  }) : super(key: key);

  final Globals _globals = getSngOf<Globals>();

  @override
  Widget build(BuildContext context) {
    
    final provInit  = context.watch<SocketConn>();
    final procProvW = context.watch<ProcessProvider>();
    final connProvW = context.watch<BrowserProvider>();
    final procProvR = context.read<ProcessProvider>();

    Widget sp10 = const SizedBox(height: 10);

    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(provInit.isLoged)
          ...[
              _icoAcc(
                isMini: true,
                isActive: (connProvW.isOk) ? true : false,
                icono: Icons.public_rounded,
                tip: 'Conecatar Browser',
                fnc: () async => _goConn('browser', context)
              ),
              sp10,
              sp10,
              MyToolTip(
                msg: 'Conexión con Mensajería',
                child: GestureDetector(
                  onTap: () async => _goConn('whatsapp', context),
                  child: Opacity(
                    opacity: (connProvW.isOk) ? 1 : 0.3,
                    child: Image.network('https://web.whatsapp.com/img/f01_3d1e81d38917ed4427168024350d8df6.png'),
                  ),
                )
              ),
              sp10,
              sp10,
              sp10,
              _icoAcc(
                isMini: true,
                isActive: false,
                icono: Icons.medical_services_outlined,
                tip: 'Test de Conección',
                fnc: () async => _goConn('test', context)
              ),
              ..._divisor(),
              sp10,
              _icoAcc(
                isActive: (procProvW.isPause)
                ? true : false,
                icono: (procProvW.isPause)
                ? Icons.play_arrow : Icons.pause_sharp,
                tip: (procProvW.isPause)
                ? 'Play' : 'Pausar',
                fnc: () => procProvR.isPause = !procProvR.isPause
              ),
              sp10,
              Selector<ProcessProvider, bool>(
                selector: (_, prov) => prov.isActiveRefresh,
                builder: (_, isAcive, child) {
                  return (isAcive)
                    ? child!
                    : const Icon(
                      Icons.refresh_outlined, size: 30, color: Color.fromARGB(255, 94, 94, 94),
                    );
                },
                child: _icoAcc(
                  isActive: false,
                  icono: Icons.refresh_outlined,
                  tip: 'Refrescar',
                  fnc: () {
                    procProvR.isRefresh = true;
                    procProvR.isActiveRefresh = !procProvR.isActiveRefresh;
                  }
                ),
              ),
              sp10,
              _icoAcc(
                isActive: false,
                icono: (!procProvW.noSendMsg)
                ? Icons.send_rounded : Icons.cancel_schedule_send_sharp,
                tip: (procProvW.noSendMsg)
                ? 'Sin Enviar Mensaje'
                : 'Enviar Mensaje',
                fnc: () { procProvR.noSendMsg = !procProvR.noSendMsg; }
              ),
              sp10,
              _icoAcc(
                isActive: false,
                icono: (procProvW.isTest)
                ? Icons.bug_report : Icons.bug_report_outlined,
                tip: (procProvW.isTest)
                ? 'Modo Test'
                : 'Modo Normal',
                fnc: () { procProvR.isTest = !procProvR.isTest; }
              ),
              ..._divisor(),
              _icoAcc(
                isActive: false,
                icono: Icons.drafts_sharp,
                tip: 'Mensaje en Proceso',
                fnc: () => onTap('msg')
              ),
              sp10,
              sp10,
              _icoWatch(context, 'Targets'),
              sp10,
              sp10,
              _icoWatch(context, 'En Espera'),
              sp10,
              sp10,
              _icoWatch(context, 'En Papelera'),
              sp10,
              sp10,
              _icoWatch(context, 'Enviados'),
            ],
          const Spacer(),
          _icoWatch(context, 'Cerrar Sesión'),
          const SizedBox(height: 10)
        ],
      ),
    );
  }

  ///
  List<Widget> _divisor() {

    Widget sp10 = const SizedBox(height: 10);
    return [
      sp10,
      sp10,
      const Divider(color: Colors.black, height: 1.5),
      const Divider(color: Color.fromARGB(255, 114, 114, 114), height: 1),
      sp10,
      sp10,
    ];
  }

  ///
  Widget _icoWatch(BuildContext context, String tip) {

    final watch = context.watch<ProcessProvider>();

    String val = '';
    String page = '';
    late IconData ico;

    switch (tip) {
      case 'En Espera':
        val = '${watch.enAwait}';
        ico = Icons.mail_outline_outlined;
        page = 'espera';
        break;
      case 'Targets':
        val = '${watch.enTray}';
        ico = Icons.share_location_outlined;
        page = 'targets';
        break;
      case 'Enviados':
        val = '${watch.sended}';
        ico = Icons.done_all;
        page = 'enviados';
        break;
      case 'En Papelera':
        val = '${watch.papelera}';
        ico = Icons.delete_outline;
        page = 'papelera';
        break;
      case 'Cerrar Sesión':
        val = '';
        ico = Icons.logout;
        page = 'closeSession';
        break;
      default:
    }

    return SizedBox(
      width: 30, height: 38,
      child: Stack(
        children: [
          _icoAcc(
            isActive: false,
            icono: ico,
            tip: tip,
            fnc: () {
              if(page == 'closeSession') {
                _cerrarSesion(context);
              }else{
                onTap(page);
              }
            }
          ),
          if(val.isNotEmpty && val != '0')
            Positioned(
              bottom: 0, right: 5,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.purple,
                child: Texto(
                  txt: val,
                  txtC: Colors.white, sz: 11,
                ),
              )
            )
        ],
      ),
    );
  }

  ///
  Widget _icoAcc({
    required IconData icono,
    required Function fnc,
    required bool isActive,
    required String tip,
    bool hasFocus = false,
    bool isMini = false})
  {
    double tam = 30;
    Color color = (isActive) ? Colors.white : Colors.grey;
    if(hasFocus) {
      color = _globals.colorEnProgreso;
    }
    if(icono == Icons.public_rounded) {
      color = _globals.sttBarrColorSt;
    }
    if(icono == Icons.medical_services_outlined) {
      color = Colors.orange;
    }
    if(icono == Icons.play_arrow) {
      color = _globals.sttBarrColorSt;
    }
    if(icono == Icons.pause) {
      color = _globals.sttBarrColorSt;
    }
    if(icono == Icons.refresh_outlined) {
      color = const Color.fromARGB(255, 233, 124, 116);
    }
    if(icono == Icons.bug_report) {
      color = _globals.sttBarrColorOn;
    }
    if(icono == Icons.cancel_schedule_send_sharp) {
      color = _globals.sttBarrColorOn;
      tam = 25;
    }
    if(icono == Icons.send_rounded) {
      tam = 25;
    }
    if(icono == Icons.play_arrow) {
      color = Colors.purple;
    }
    if(icono == Icons.pause_sharp) {
      color = Colors.red;
    }

    return MyToolTip(
      msg: tip,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        constraints: BoxConstraints(
          maxWidth: (isMini) ? 20 : tam
        ),
        iconSize: (isMini) ? 20 : tam,
        visualDensity: VisualDensity.compact,
        onPressed: () => fnc(),
        icon: Icon(icono, color: color)
      )
    );
  }

  ///
  void _goConn(String to, BuildContext context) {

    final nav = Navigator.of(context);
    final procProvR = context.read<ProcessProvider>();

    if(procProvR.seccBrowConn.isNotEmpty) {
      nav.pop();
    }

    int page = 0;
    switch (to) {
      case 'whatsapp':
         page = 1;
        break;
      case 'test':
         page = 2;
        break;
      default:
        page = 0;
    }
    procProvR.seccBrowConn = to;
    nav.push(
      MaterialPageRoute(
        builder: (_) => ConnectView(page: page, onClose: (_){})
      )
    );
  }

  ///
  void _cerrarSesion(BuildContext context) async {
    
    final sock = context.read<SocketConn>();
    final proc = context.read<ProcessProvider>();
    final cons = context.read<TerminalProvider>();
    final bros = context.read<BrowserProvider>();
    proc.cleanProcess();
    proc.cleanCampaingCurrent();
    proc.cleanReloadMsgAcction();
    bros.cerrarSesion();
    cons.taskTerminal.clear();
    cons.terminalIsMini = true;
    proc.cerrarSesion();
    sock.cerrarConection();
    final nav = Navigator.of(context);
    await Future.delayed(const Duration(milliseconds: 250));
    sock.isLoged = false;
    if(nav.canPop()) {
      nav.pop();
    }
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginPage()
      )
    );
  }
  
  ///
  Future<void> time() async => await Future.delayed(const Duration(milliseconds: 1000));
}