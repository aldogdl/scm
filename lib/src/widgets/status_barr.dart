import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/pages/views/config_page.dart';

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
    final sock = context.watch<SocketConn>();
    final fecha = MyUtils.getFecha(fecha: proc.initRR);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(isLoged)
          if(!sock.isShowConfig)
            _btnIcon(tip: 'Configuración',
              icono: Icons.settings,
              fnc: () {
                sock.isShowConfig = true;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConfigPage()
                  )
                );
              }
            )
          else
            const SizedBox(width: 15),
          const SizedBox(width: 10),
          _btnTxt(
            label: 'Ver.: ${proc.verScm}',
            fnc: (){}
          ),
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
            tip: (procW.isStopCronFles) ? 'DETENIDO' : 'Número de Revisión Local / ${proc.cadaL} Seg.',
            fnc: () async {
              if(proc.isStopCronFles) {
                await proc.initCronFolderLocal();
              }else{
                await proc.cron.close();
                Future.microtask(() => proc.isStopCronFles = true );
              }
            }
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
    bool isReverse = false}) 
  {

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
    required Function fnc}) 
  {

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
    required Function fnc})
  {

    return TextButton(
      onPressed: () => fnc(),
      child: Texto(
        txt: label, sz: 13, txtC: const Color(0xffFFFFFF), 
      )
    );
  }

}