import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'texto.dart';
import '../services/my_utils.dart';
import '../providers/process_provider.dart';
import '../providers/socket_conn.dart';

class StatusBarr extends StatelessWidget {

  final Color bgOff;
  final Color bgOn;
  const StatusBarr({
    Key? key,
    required this.bgOff,
    required this.bgOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Selector<SocketConn, bool>(
      selector: (_, provi) => provi.isLoged,
      builder: (_, isLoged, child) {

        return Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 25,
          decoration: BoxDecoration(
            color: (isLoged) ? bgOn : bgOff
          ),
          child: _body(context, isLoged),
        );
      },
    );
  }

  ///
  Widget _body(BuildContext context, bool isLoged) {

    final proc = context.read<ProcessProvider>();
    final procW = context.watch<ProcessProvider>();
    final fecha = MyUtils.getFecha(fecha: proc.initRR);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(isLoged)
          _btnIcon(tip: 'Cerrar Sesión',
            icono: Icons.logout,
            fnc: () {
              final sock = context.read<SocketConn>();
              proc.cerrarSesion();
              sock.cerrarConection();
              sock.isLoged = false;
          }),
          const Spacer(),
          _btnTxt(
            label: 'Desde: ${fecha['mini']}',
            fnc: (){}
          ),
          const SizedBox(width: 10),
          _btnIconAndTxt(
            icono: (!procW.isStopCronFles)
            ? Icons.remove_red_eye_outlined : Icons.maximize_outlined,
            txt: '${procW.timer}',
            tip: 'Número de Revisión Local / ${proc.cadaL} Seg.',
            fnc: (){}
          ),
          _btnIconAndTxt(
            icono: (!procW.isStopCronStage)
            ? Icons.remove_red_eye_outlined : Icons.maximize_outlined,
            txt: '${procW.timerS}',
            tip: 'Número de Revisión al Stage / ${proc.cadaS} Seg.',
            fnc: (){}
          ),
      ],
    );
  }

  ///
  Widget _btnIconAndTxt({
    required IconData icono,
    required String txt,
    required String tip,
    required Function fnc,
    bool isReverse = false
  }) {

    BoxConstraints constraint = const BoxConstraints(
      maxHeight: 15, minWidth: 30
    );
    if(icono.codePoint == 61882) {
      constraint = const BoxConstraints(
        maxHeight: 5, minWidth: 30
      );
    }
    
    Widget ico = IconButton(
      onPressed: () => fnc(),
      icon: Icon(icono),
      padding: const EdgeInsets.all(0),
      visualDensity: VisualDensity.compact,
      tooltip: tip,
      alignment: Alignment.center,
      color: const Color(0xFFFFFFFF),
      iconSize: 15,
      constraints: constraint,
    );
    Widget lab = Texto(txt: txt, sz: 12, txtC: const Color(0xFFFFFFFF));

    if(isReverse) {
      return Row(children: [ico, lab ]);
    }else{
      return Row(children: [lab, ico]);
    }
  }

  ///
  Widget _btnIcon({
    required IconData icono,
    required String tip,
    required Function fnc,
  }) {

    return IconButton(
      onPressed: () => fnc(),
      icon: Icon(icono),
      padding: const EdgeInsets.all(0),
      visualDensity: VisualDensity.compact,
      tooltip: tip,
      alignment: Alignment.center,
      color: const Color(0xFFFFFFFF),
      iconSize: 15,
      constraints: const BoxConstraints(
        maxHeight: 15, maxWidth: 15
      ),
    );
  }

  ///
  Widget _btnTxt({
    required String label,
    required Function fnc,
  }) {

    return TextButton(
      onPressed: () => fnc(),
      child: Texto(
        txt: label, sz: 13, txtC: const Color(0xffFFFFFF), 
      )
    );
  }

}