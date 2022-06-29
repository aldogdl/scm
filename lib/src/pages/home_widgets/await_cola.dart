import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/my_tool_tip.dart';
import '../../widgets/sin_data.dart';
import '../../widgets/texto.dart';
import 'cola_barr_div.dart';

class AwaitCola extends StatefulWidget {

  const AwaitCola({Key? key}) : super(key: key);

  @override
  State<AwaitCola> createState() => _AwaitColaState();
}

class _AwaitColaState extends State<AwaitCola> {

  final ScrollController _ctrScrollAwait = ScrollController();
  
  late ProcessProvider _proc;
  bool _isInit = false;
  List<ScmEntity> _lstAwait = [];
  int _cantEnAwait = 0;
  int _totalFind = 0;

  @override
  void dispose() {
    _ctrScrollAwait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.symmetric(
        vertical: 3, horizontal: 10
      ),
      constraints: BoxConstraints.expand(
        width: appWindow.size.width,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          Expanded(
            child: _body(),
          ),
          const ColaBarrDiv()
        ],
      )
    );
  }

  ///
  Widget _body() {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
      _proc.setTituloColaBarr = 'Cargando...';
    }
    
    return Selector<ProcessProvider, int>(
      selector: (_, provi) => provi.enAwait,
      builder: (_, cantEnAway, child) {
        
        Future.delayed(const Duration(milliseconds: 150), (){
          _proc.tituloColaBarr = '$_totalFind msg(s). Campaña ID.: ${_proc.enProceso.id}';
        });
        if(cantEnAway == 0) { return child!; }
        if(cantEnAway != _cantEnAwait) {
          _cantEnAwait = cantEnAway;
          return _createList(child!);
        }
        return child!;
      },
      child: const SinData(
        msg: '', main: 'nada en Cola', isDark: false,
        withTit: false
      ),
    );
  }

  ///
  Widget _createList(Widget child) {

    return FutureBuilder(
      future: _getMsgs(),
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {
          if(_lstAwait.isNotEmpty) {
            return _buildLst();
          }
        }
        return child;
      }
    );
  }

  ///
  Widget _buildLst() {

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(
        controller: _ctrScrollAwait,
        thumbVisibility: true,
        radius: const Radius.circular(3),
        child: ListView.builder(
          padding: const EdgeInsets.only(right: 15, left: 10),
          shrinkWrap: true,
          controller: _ctrScrollAwait,
          itemCount: _lstAwait.length,
          itemBuilder: (_, int i) => _tileReceiver(_lstAwait[i], i+1)
        )
      )
    );
  }

  /// El diseño para el receptor dentro de la cola
  Widget _tileReceiver(ScmEntity receiver, int index) {

    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20, height: 15,
                  child: Checkbox(
                    checkColor: Colors.white.withOpacity(0.5),
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: Colors.grey),
                    fillColor: MaterialStateProperty.all(
                      Colors.white.withOpacity(0.1)
                    ),
                    key: Key('${receiver.idReceiver}'),
                    value: !receiver.forceNotSend,
                    onChanged: (val) {
                      val = (val == null) ? false : val;
                      val = !val;
                      setState(() {
                        receiver.forceNotSend = val ?? false;
                      });
                    }
                  ),
                ),
                const SizedBox(height: 2),
                Texto(
                  txt: '# $index', sz: 12, isCenter: true,
                  txtC: const Color.fromARGB(255, 145, 255, 0)
                ),
              ],
            ),
            const SizedBox(width: 8),
            MyToolTip(
              msg: '-> ${receiver.nombre}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texto(
                    txt: receiver.nombre,
                    txtC: const Color.fromARGB(255, 224, 224, 224)
                  ),
                  Texto(
                    txt: receiver.receiver.empresa, sz: 11,
                    txtC: const Color.fromARGB(255, 149, 151, 243)
                  )
                ],
              )
            ),
            const Spacer(),
            Selector<ProcessProvider, bool>(
              selector: (_, prov) => prov.isPause,
              builder: (_, val, __) {
                return Texto(
                  txt: (val) ? 'En Pausa' : 'En cola', sz: 12,
                  txtC: const Color.fromARGB(255, 145, 255, 0)
                );
              },
            ),
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5),)
      ],
    );
  }


  // ----------------CONTROLADOR--------------------


  /// Recuperamos los mensajes de la campaña actual
  Future<void> _getMsgs() async {

    _lstAwait = [];

    final msgs = List<String>.from(_proc.enProceso.noSend);
    _totalFind = msgs.length;
    if(msgs.isNotEmpty) {
      _lstAwait = await GetContentFile.getAllReceiverOfCampaings(
        filesRecivers: msgs, fileNameCurrent: _proc.currentFileReceiver
      );
    }
  }
  
}