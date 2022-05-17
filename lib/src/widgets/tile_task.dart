import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_tool_tip.dart';
import 'texto.dart';
import '../providers/process_provider.dart';
import '../entity/proceso_entity.dart';

class TileTask extends StatefulWidget {

  final ProcesoEntity proc;
  final String accType;
  final int index;
  final ValueChanged<int> onChangeFolder;
  const TileTask({
    Key? key,
    required this.proc,
    required this.index,
    required this.accType,
    required this.onChangeFolder
  }) : super(key: key);

  @override
  State<TileTask> createState() => _TileTaskState();
}

class _TileTaskState extends State<TileTask> {

  final Widget _sp5 = const SizedBox(width: 5);

  @override
  Widget build(BuildContext context) {


    return const SizedBox();

    // return Container(
    //   padding: const EdgeInsets.all(8),
    //   margin: const EdgeInsets.only(top: 8),
    //   decoration: BoxDecoration(
    //     color: Colors.black.withOpacity(0.3),
    //     borderRadius: BorderRadius.circular(5)
    //   ),
    //   child: Column(
    //     children: [
    //       Row(
    //         children: [
    //           Texto(txt: widget.proc.tit.toUpperCase(), sz: 13,),
    //           const Spacer(),
    //           Texto(
    //             txt: 'ID: ${widget.proc.orden.id}',
    //             txtC: Colors.white, isBold: true,
    //           )
    //         ],
    //       ),
    //       const Divider(),
    //       Row(
    //         children: [
    //           const Icon(Icons.directions_car_filled, size: 16, color: Colors.green),
    //           _sp5,
    //           MyToolTip(
    //             msg: widget.proc.orden.marca,
    //             child: Texto(
    //               txt: widget.proc.orden.modelo,
    //               txtC: Colors.blueGrey, isBold: true
    //             ),
    //           ),
    //           _sp5,
    //           Texto(txt: '${widget.proc.orden.anio}'),
    //           const SizedBox(width: 15),
    //           Texto(
    //             txt: (widget.proc.orden.isNac) ? 'NACIONAL' : 'IMPORTADO',
    //             txtC: Colors.white.withOpacity(0.8), sz: 13,
    //           ),
    //           const Spacer(),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           const Icon(Icons.account_circle_rounded, size: 16, color: Colors.green),
    //           _sp5,
    //           Texto(
    //             txt: widget.proc.own.nombre,
    //             txtC: Colors.blueGrey
    //           ),
    //           const Spacer(),
    //           Texto(
    //             txt: widget.proc.own.empresa,
    //             txtC: Colors.white.withOpacity(0.8), sz: 13,
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 10),
    //       Row(
    //         children: [
    //           const Icon(Icons.sell_rounded, size: 16, color: Colors.green),
    //           _sp5,
    //           Texto(
    //             txt: 'Att. AVO: ${ widget.proc.avo.nombre }',
    //             txtC: Colors.blueGrey
    //           ),
    //           const Spacer(),
    //           Texto(
    //             txt: widget.proc.avo.curc,
    //             txtC: Colors.white.withOpacity(0.8), sz: 13,
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 5),
    //       const Divider(color: Color.fromARGB(255, 71, 71, 71), height: 1),
    //       _determinarAcciones(),
    //       const Divider(color: Color.fromARGB(255, 71, 71, 71), height: 1),
    //     ],
    //   ),
    // );
  }

  // ///
  // Widget _determinarAcciones() {

  //   switch (widget.accType) {
  //     case 'sended':
  //       return _barraDeAccSended();
  //     case 'papelera':
  //       return _barraDeAccPapelera();
  //     default:
  //       return _barraDeAccLstMsgs();
  //   }
  // }

  // ///
  // Widget _barraDeAccLstMsgs() {

  //   final rec = widget.proc.orden.createdAt;
  //   final fecha = '${rec!.day}-${rec.month}-${rec.year}  ${rec.hour}:${rec.minute}';

  //   return _layoutAcciones([
  //     Texto(txt: fecha),
  //     const Spacer(),
  //     _icoAcc(
  //       msg: 'Detener su Proceso', ico: Icons.back_hand,
  //       clr: Colors.orangeAccent,
  //       fnc: (){}
  //     ),
  //     _icoAcc(
  //       msg: 'Pausar el Envio', ico: Icons.pause_circle_outline,
  //       clr: const Color.fromARGB(255, 223, 171, 167),
  //       fnc: (){}
  //     ),
  //     _icoAcc(
  //       msg: 'Enviar a Papelera', ico: Icons.delete,
  //       clr: const Color.fromARGB(255, 238, 93, 82),
  //       fnc: () async {
  //         // await GetContentFile.changeDeFolder(
  //         //   from: widget.proc.path, to: 'scm_drash'
  //         // );
  //         // widget.onChangeFolder(widget.index);
  //         print(widget.proc.toJson());
  //       }
  //     ),
  //     _icoAcc(
  //       msg: 'Marcar como Enviado', ico: Icons.done_all,
  //       clr: const Color.fromARGB(255, 92, 82, 238),
  //       fnc: () async {
  //         // await GetContentFile.changeDeFolder(
  //         //   from: widget.proc.path, to: 'scm_sended'
  //         // );
  //         // widget.onChangeFolder(widget.index);
  //       }
  //     ),
  //   ]);
  // }

  // ///
  // Widget _barraDeAccSended() {

  //   final rec = widget.proc.orden.createdAt;
  //   final fecha = '${rec!.day}-${rec.month}-${rec.year}  ${rec.hour}:${rec.minute}';

  //   return _layoutAcciones([
  //     Texto(txt: fecha),
  //     const Spacer(),
  //     _icoAcc(
  //       msg: 'Reenviar Mensaje', ico: Icons.settings_backup_restore_sharp,
  //       clr: Colors.orangeAccent,
  //       fnc: () async {
  //         // await GetContentFile.changeDeFolder(
  //         //   from: widget.proc.path, to: 'scm_await'
  //         // );
  //         // widget.onChangeFolder(widget.index);
  //       }
  //     ),
  //   ]);
  // }

  // ///
  // Widget _barraDeAccPapelera() {

  //   final rec = widget.proc.orden.createdAt;
  //   final fecha = '${rec!.day}-${rec.month}-${rec.year}  ${rec.hour}:${rec.minute}';

  //   return _layoutAcciones([
  //     Texto(txt: fecha),
  //     const Spacer(),
  //     _icoAcc(
  //       msg: 'Enviar a Cola', ico: Icons.send_and_archive_outlined,
  //       clr: Colors.orangeAccent,
  //       fnc: () async {
  //         // await GetContentFile.changeDeFolder(
  //         //   from: widget.proc.path, to: 'scm_await'
  //         // );
  //         // widget.onChangeFolder(widget.index);
  //       }
  //     ),
  //   ]);
  // }

  // ///
  // Widget _layoutAcciones(List<Widget> children) {

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     constraints: BoxConstraints.expand(
  //       height: MediaQuery.of(context).size.height * 0.04,
  //     ),
  //     decoration: const BoxDecoration(
  //       color: Color.fromARGB(255, 31, 31, 31),
  //       border: Border(
  //         top: BorderSide(
  //           color: Colors.black
  //         ),
  //         bottom: BorderSide(
  //           color: Colors.black
  //         )
  //       )
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: children,
  //     ),
  //   );
  // }

  // ///
  // Widget _icoAcc({
  //   required String msg,
  //   required IconData ico,
  //   required Color clr,
  //   required Function fnc,
  // }) {

  //   return Padding(
  //     padding: const EdgeInsets.only(left: 10),
  //     child: MyToolTip(
  //     msg: msg,
  //       child: IconButton(
  //         padding: const EdgeInsets.all(0),
  //         visualDensity: VisualDensity.comfortable,
  //         constraints: const BoxConstraints(),
  //         onPressed: () => fnc(),
  //         icon: Icon(ico, size: 19, color: clr)
  //       )
  //     ),
  //   );
  // }

}