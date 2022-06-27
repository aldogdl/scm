import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'cola_barr_div.dart';
import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/my_tool_tip.dart';
import '../../widgets/sin_data.dart';
import '../../widgets/texto.dart';

class AwaitCola extends StatefulWidget {

  const AwaitCola({Key? key}) : super(key: key);

  @override
  State<AwaitCola> createState() => _AwaitColaState();
}

class _AwaitColaState extends State<AwaitCola> {

  final ScrollController _ctrScrollAwait = ScrollController();
  final ScrollController _ctrScrollTray = ScrollController();
  
  late ProcessProvider _proc;
  bool _isInit = false;
  List<ScmEntity> _lstAwait = [];
  
  @override
  void dispose() {
    _ctrScrollAwait.dispose();
    _ctrScrollTray.dispose();
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
            child: Selector<ProcessProvider, int>(
              selector: (_, provi) => provi.enAwait,
              builder: (_, cantEnAway, child) {
                print('cambia aweit');
                if(cantEnAway == 0) { return child!; }
                return FutureBuilder(
                  future: _getMsgs(),
                  builder: (_, AsyncSnapshot snap) {

                    if(snap.connectionState == ConnectionState.done) {
                      if(_lstAwait.isNotEmpty) {
                        return _buildLst();
                      }
                    }
                    return child!;
                  }
                 );
                
              },
              child: const SinData(
                msg: '', main: 'nada en Cola', isDark: false,
                withTit: false
              ),
            ),
          ),
          const ColaBarrDiv()
        ],
      ),
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
          itemBuilder: (_, int i) => _tileReceiver(_lstAwait[i])
        )
      )
    );
  }

  /// El diseño para el receptor dentro de la cola
  Widget _tileReceiver(ScmEntity receiver) {

    return Column(
      children: [
        Row(
          children: [
            if(receiver.idReceiver == _proc.receiverCurrent.idReceiver)
              const SizedBox(
                width: 15, height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )
              )
            else
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
            const SizedBox(width: 8),
            MyToolTip(
              msg: '-> ${receiver.nombre}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texto(
                    txt: receiver.receiver.empresa,
                    txtC: const Color.fromARGB(255, 149, 151, 243)
                  ),
                  Texto(
                    txt: receiver.nombre, sz: 11,
                    txtC: const Color.fromARGB(255, 224, 224, 224)
                  )
                ],
              )
            ),
            const Spacer(),
            Texto(
              txt: (context.watch<ProcessProvider>().isPause)
                ? 'En Pausa' : 'En cola', sz: 12,
              txtC: const Color.fromARGB(255, 145, 255, 0)
            )
          ],
        ),
        Divider(color: Colors.grey.withOpacity(0.5),)
      ],
    );
  }


  // ----------------CONTROLADOR--------------------


  /// Recuperamos os mensajes de la campaña actual
  Future<void> _getMsgs() async {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
      _proc.setTituloColaBarr = 'Cargando...';
    }
    _lstAwait = [];
    print('gastando recursos');
    final msgs = List<String>.from(_proc.enProceso.noSend);
    if(msgs.isNotEmpty) {
      _lstAwait = await GetContentFile.getAllReceiverOfCampaings(
        filesRecivers: msgs, fileNameCurrent: _proc.currentFileReveiver
      );
    }
    _proc.tituloColaBarr = '${msgs.length} msg(s). Campaña: ${_proc.enProceso.id}';
  }

}