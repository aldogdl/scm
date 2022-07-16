import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/sng_manager.dart';
import '../providers/socket_conn.dart';
import '../providers/process_provider.dart';
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
    
    final provInit = context.watch<SocketConn>();
    final procProvW = context.watch<ProcessProvider>();
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
                isActive: false,
                icono: Icons.refresh,
                tip: 'Refrescar',
                fnc: () async {
                  procProvW.setReloadMsgAcction('En espera de Mensajes');
                  procProvW.cleanCampaingCurrent();
                  final nav = Navigator.of(context);
                  await procProvW.initCronFolderLocal();
                  if(procProvW.isStopCronStage) {
                    procProvW.initCronFolderStage();
                  }
                  procProvW.isRefresh = true;
                  Future.delayed(const Duration(microseconds: 1000), (){
                    procProvW.isRefresh = false;
                  });
                  if(nav.canPop()) { nav.pop(); }
                }
              ),
              ..._divisor(),
              Stack(
                children: [
                  _icoAcc(
                    isActive: false,
                    icono: (procProvW.isPause)
                    ? Icons.play_arrow : Icons.pause,
                    tip: (procProvW.isPause)
                    ? 'Poner en PLAY'
                    : 'Pausar Proceso',
                    fnc: () { procProvR.isPause = !procProvR.isPause; }
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
                icono: (!procProvW.noSend)
                ? Icons.send_rounded : Icons.cancel_schedule_send_sharp,
                tip: (procProvW.noSend)
                ? 'Sin Enviar Mensaje'
                : 'Enviar Mensaje',
                fnc: () { procProvR.noSend = !procProvR.noSend; }
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


}