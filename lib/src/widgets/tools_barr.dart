
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/sng_manager.dart';
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
    
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height
      ),
      child: Selector<SocketConn, bool>(
        selector: (_, prov) => prov.isLoged,
        builder: (_, isLoged, __) => _btnsLoged(context, isLoged)
      ),
    );
  }

  ///
  Widget _btnsLoged(BuildContext context, bool isLoged) {

    final procProvR = context.read<ProcessProvider>();

    Widget sp10 = const SizedBox(height: 10);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(isLoged)
        ...[
            ... _divisor(topSp: false),
            sp10,
            Selector<ProcessProvider, bool>(
              selector: (_, prov) => prov.isTest,
              builder: (_, isTest, __) {
                return _icoAcc(
                  isActive: false,
                  icono: (isTest)
                  ? Icons.bug_report : Icons.bug_report_outlined,
                  tip: (isTest)
                  ? 'Modo Test'
                  : 'Modo Normal',
                  fnc: () { procProvR.isTest = !procProvR.isTest; }
                );
              }
            ),
            sp10,
            _icoAcc(
              isActive: false,
              icono: Icons.refresh_outlined,
              tip: 'Refrescar',
              fnc: () {
                procProvR.isPause = true;
                procProvR.noSendMsg = true;
                procProvR.isProcessWorking = true;
                procProvR.isStopCronFiles = true;
                Future.delayed(const Duration(milliseconds: 350), (){
                  
                  procProvR.cleanCampaingCurrent();
                  procProvR.cleanProcess();
                  procProvR.refreshTray = 0;
                  procProvR.receiverViewer = -1;

                  Future.microtask(() {
                    procProvR.isRefresh = true;
                    final conn = context.read<BrowserProvider>();
                    conn.isOkCp = false;
                    procProvR.systemIsOk = 0;
                  });
                });
              }
            ),
            sp10,
            Selector<ProcessProvider, bool>(
              selector: (_, prov) => prov.noSendMsg,
              builder: (_, noSendMsg, __) {
                return _icoAcc(
                  isActive: false,
                  icono: (!noSendMsg)
                  ? Icons.send_rounded : Icons.cancel_schedule_send_sharp,
                  tip: (noSendMsg)
                  ? 'Sin Enviar Mensaje'
                  : 'Enviar Mensaje',
                  fnc: () { procProvR.noSendMsg = !procProvR.noSendMsg; }
                );
              }
            ),
            sp10,
            sp10,
            sp10,
            Selector<ProcessProvider, bool>(
              selector: (_, prov) => prov.isPause,
              builder: (_, isP, __) {

                return _icoAcc(
                  isActive: (isP) ? true : false,
                  icono: (isP)
                  ? Icons.play_arrow : Icons.pause_sharp,
                  tip: (isP)
                  ? 'Play' : 'Pausar',
                  fnc: () => procProvR.isPause = !procProvR.isPause
                );
              }
            ),
            ..._divisor(),
            sp10,
            sp10,
            _icoAcc(
              isActive: false,
              icono: Icons.drafts_sharp,
              tip: 'Mensaje en Proceso',
              fnc: () => onTap('msg')
            ),
            sp10,
            sp10,
            Selector<ProcessProvider, int>(
              selector: (_, prov) => prov.enAwait,
              builder: (_, val, __) {
                return _icoWatch(context, 'En Espera', val);
              }
            ),
            sp10,
            sp10,
            Selector<ProcessProvider, int>(
              selector: (_, prov) => prov.papelera,
              builder: (_, val, __) {
                return _icoWatch(context, 'En Papelera', val);
              }
            ),
            sp10,
            sp10,
            Selector<ProcessProvider, int>(
              selector: (_, prov) => prov.sended,
              builder: (_, val, __) {
                return _icoWatch(context, 'Enviados', val);
              }
            ),
          ],
        const Spacer(),
        Selector<ProcessProvider, bool>(
          selector: (_, prov) => prov.isStopCronFiles,
          builder: (_, val, __) {

            return _icoAcc(
              tip: (val)
                ? 'Iniciar Monitoreo'
                : 'Deterner Monitoreo',
              isActive: (val) ?  false : true,
              icono: (val)
                ? Icons.visibility_off
                : Icons.remove_red_eye, isMini: true,
              iconColor: (context.watch<ProcessProvider>().isProcessWorking)
                ? const Color.fromARGB(255, 52, 185, 56)
                : Colors.white,
              fnc: () async {
                if(val) {
                  await procProvR.initCronFolderLocal();
                }else{
                  await procProvR.cron.close();
                }
                Future.microtask(() {
                  procProvR.isStopCronFiles = !val;
                });
              }
            );
          }
        ),
        const SizedBox(height: 10),
        _icoAcc(
          tip: 'Configuración', isActive: false,
          icono: Icons.settings, isMini: true,
          fnc: () => onTap('')
        ),
        const SizedBox(height: 10),
        _icoAcc(
          tip: 'Cerrar Sesión', isActive: false,
          icono: Icons.logout, isMini: true,
          fnc: () => _cerrarSesion(context)
        ),
        const SizedBox(height: 5)
      ],
    );
  }

  ///
  List<Widget> _divisor({bool topSp = true}) {

    Widget sp10 = const SizedBox(height: 6);
    return [
      if(topSp)
        sp10,
      sp10,
      const Divider(color: Colors.black, height: 1.5),
      const Divider(color: Color.fromARGB(255, 114, 114, 114), height: 1),
      sp10,
      sp10,
    ];
  }

  ///
  Widget _icoWatch
    (BuildContext context, String tip, int val, {isMini = false})
  {

    String page = '';
    late IconData ico;
    double tam = 25.0;
    if(isMini) {
      tam = 20.0;
    }
    switch (tip) {
      case 'En Espera':
        ico = Icons.mail_outline_outlined;
        page = 'espera';
        break;
      case 'Targets':
        ico = Icons.share_location_outlined;
        page = 'targets';
        break;
      case 'Enviados':
        ico = Icons.done_all;
        page = 'enviados';
        break;
      case 'En Papelera':
        ico = Icons.delete_outline;
        page = 'papelera';
        break;
      default:
    }
    
    String valor = '$val';
    return SizedBox(
      width: tam, height: tam+5,
      child: Stack(
        children: [
          _icoAcc(
            isActive: false,
            icono: ico,
            isMini: isMini,
            tip: tip,
            fnc: () => onTap(page)
          ),
          if(valor.isNotEmpty && valor != '0')
            Positioned(
              bottom: 0, right: 5,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.purple,
                child: Texto(
                  txt: valor,
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
    Color? iconColor,
    bool hasFocus = false,
    bool isMini = false})
  {

    double tam = (isMini) ? 20 : 25;
    
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
    }
    if(icono == Icons.send_rounded) {
    }
    if(icono == Icons.play_arrow) {
      color = Colors.purple;
    }
    if(icono == Icons.pause_sharp) {
      color = Colors.red;
    }

    if(iconColor != null) {
      color = iconColor;
    }
    return MyToolTip(
      msg: tip,
      child: IconButton(
        padding: const EdgeInsets.only(bottom: 7),
        constraints: BoxConstraints(
          maxWidth: tam,
        ),
        iconSize: tam,
        visualDensity: VisualDensity.compact,
        onPressed: () => fnc(),
        icon: Icon(icono, color: color)
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
    proc.cerrarSesionProcess();

    bros.cerrarSesion();
    cons.taskTerminal.clear();
    sock.cerrarConection();
    await Future.delayed(const Duration(milliseconds: 250));
    sock.isLoged = false;
  }
  
  ///
  Future<void> time() async => await Future.delayed(const Duration(milliseconds: 1000));
}