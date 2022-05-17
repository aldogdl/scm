import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

import '../config/sng_manager.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
import '../vars/globals.dart';
import '../vars/mis_rutas.dart';
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
    
    final _provInit = context.watch<SocketConn>();
    final _procProv = context.watch<ProcessProvider>();

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
          if(_provInit.isLoged)
          ...[
              _icoAcc(
                isMini: true,
                isActive: false,
                icono: Icons.refresh,
                tip: 'Refrescar',
                fnc: () => _refrezcarPagina(context, _procProv)
              ),
              ..._divisor(),
              Stack(
                children: [
                  _icoAcc(
                    isActive: false,
                    icono: (context.watch<ProcessProvider>().isPause)
                    ? Icons.play_arrow : Icons.pause,
                    tip: (context.watch<ProcessProvider>().isPause)
                    ? 'Poner en PLAY'
                    : 'Pausar Proceso',
                    fnc: () {
                      context.read<ProcessProvider>().isPause = !context.read<ProcessProvider>().isPause;
                    }
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Selector<ProcessProvider, bool>(
                      selector: (_, provi) => provi.termitente,
                      builder: (_, isPause, __) {
                        return CircleAvatar(
                          radius: 3,
                          backgroundColor: (isPause) ? Colors.blue : _globals.sidebarColor,
                        );
                      },
                    )
                  )
                ],
              ),
              sp10,
              _icoAcc(
                isActive: false,
                icono: (!context.watch<ProcessProvider>().noSend)
                ? Icons.send_rounded : Icons.cancel_schedule_send_sharp,
                tip: (context.watch<ProcessProvider>().noSend)
                ? 'Sin Enviar Mensaje'
                : 'Enviar Mensaje',
                fnc: () {
                  context.read<ProcessProvider>().noSend = !context.read<ProcessProvider>().noSend;
                }
              ),
              sp10,
              _icoAcc(
                isActive: false,
                icono: (context.watch<ProcessProvider>().isTest)
                ? Icons.bug_report : Icons.bug_report_outlined,
                tip: (context.watch<ProcessProvider>().isTest)
                ? 'Modo Test'
                : 'Modo Normal',
                fnc: () {
                  context.read<ProcessProvider>().isTest = !context.read<ProcessProvider>().isTest;
                }
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
              _icoAcc(
                isActive: false,
                icono: Icons.share_location_outlined,
                tip: 'Target',
                fnc: () => onTap('target')
              ),
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
          _icoWatch(context, 'Configuración'),
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
      case 'Configuración':
        val = '';
        ico = Icons.settings;
        page = 'config';
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
            fnc: () => onTap(page)
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
    bool isMini = false
  }) {

    double tam = 30;
    Color color = (isActive) ? Colors.white : Colors.grey;
    if(hasFocus) {
      color = _globals.colorEnProgreso;
    }
    if(icono == Icons.play_arrow) {
      color = _globals.sttBarrColorSt;
    }
    if(icono == Icons.pause) {
      color = _globals.sttBarrColorSt;
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
  void _refrezcarPagina(BuildContext context, ProcessProvider _procProv) {

    _procProv.stopAllCrones();
    _procProv.isPause = true;
    _procProv.cambiarDeCampaing();
    _procProv.reloadMsgAcction = 'Revisando prioridades';
    Routemaster.of(context).pop();
  }
}