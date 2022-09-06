import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scm/src/widgets/sin_data.dart';
import 'package:scm/src/widgets/titulo_seccion.dart';

import '../../providers/process_provider.dart';
import '../../widgets/texto.dart';
import '../../widgets/tile_contacts.dart';

class MsgCurrent extends StatefulWidget {

  const MsgCurrent({Key? key}) : super(key: key);

  @override
  State<MsgCurrent> createState() => _MsgCurrentState();
}

class _MsgCurrentState extends State<MsgCurrent> {

  late final ProcessProvider _proc;
  
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: (_proc.enProceso.id == 0)
      ? const SinData(
          msg: '', main: 'Campaña Seleccionada'
        )
      :
      Column(
        children: [
          const TituloSeccion(titulo: 'Mensaje en Proceso'),
          const SizedBox(height: 8),
          _elMensaje(),
          const SizedBox(height: 5),
          TileContacts(
            isDark: true,
            title: '-> REMITENTE',
            idCamp: _proc.enProceso.id,
            nombre: _proc.enProceso.remiter.nombre,
            subTi: 'Cargo: ${_proc.enProceso.remiter.cargo}',
            celular: _proc.enProceso.remiter.celular,
            curc: _proc.enProceso.emiter.curc,
          ),
          const SizedBox(height: 10),
          TileContacts(
            isDark: true,
            title: '-> ASESOR DE VENTAS ONLINE',
            idCamp: _proc.enProceso.id,
            nombre: _proc.enProceso.emiter.nombre,
            subTi: 'CURC: ${_proc.enProceso.emiter.curc}',
            celular: _proc.enProceso.emiter.celular,
            curc: _proc.enProceso.emiter.curc,
          ),
        ]
      ),
    );
  }

  ///
  Widget _elMensaje() {

    return Container(
      constraints: BoxConstraints(
        minWidth: appWindow.size.width,
        minHeight: appWindow.size.height * 0.29,
        maxHeight: appWindow.size.height * 0.30
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(0.9)
        ),
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 224, 224, 224).withOpacity(0.65)
      ),
      child: ListView.builder(
        itemCount: _proc.msgCurrent.length,
        itemBuilder: (_, int i) {

          if(_proc.msgCurrent[i].contains('_sp_')) {
            return const SizedBox(height: 5);
          }else{
            return Texto(
              txt: _proc.msgCurrent[i], txtC: const Color.fromARGB(255, 43, 43, 43)
            );
          }
        },
      )
    );
  }

}