import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'cola_barr_div.dart';
import '../../entity/proceso_entity.dart';
import '../../entity/scm_entity.dart';
import '../../providers/process_provider.dart';
import '../../services/get_content_files.dart';
import '../../vars/scroll_config.dart';
import '../../widgets/indicador_cola.dart';
import '../../widgets/tile_await_camp.dart';
import '../../widgets/sin_data.dart';

class AwaitCola extends StatefulWidget {

  const AwaitCola({Key? key}) : super(key: key);

  @override
  State<AwaitCola> createState() => _AwaitColaState();
}

class _AwaitColaState extends State<AwaitCola> {

  final ScrollController _ctrScrollAwait = ScrollController();
  
  late ProcessProvider _proc;
  late Future<void> _getAwait;
  bool _isInit = false;
  List<ScmEntity> _lstAwait = [];
  int _cantLast = 0;

  @override
  void initState() {
    _getAwait = _getReceptores();
    super.initState();
  }

  @override
  void dispose() {
    _ctrScrollAwait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _getAwait,
      builder: (_, AsyncSnapshot snap) {
        
        if(snap.connectionState == ConnectionState.done) {
          if(_lstAwait.isNotEmpty) { return _body(); }
        }
        return _sinData();
      }
    );
  }

  ///
  Widget _body() {

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 3, horizontal: 10
      ),
      width: appWindow.size.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Column(
        children: [
          _indicador(),
          Expanded(
            child: _buildLst(),
          ),
          const ColaBarrDiv()
        ],
      )
    );
  }

  ///
  Widget _sinData() {

    return const SinData(
      msg: '', main: 'nada en Cola', isDark: false,
      withTit: false
    );
  }

  ///
  Widget _indicador() {

    return Selector<ProcessProvider, ProcesoEntity>(
      selector: (_, provi) => provi.enProceso,
      builder: (_, trigger, __) {
        
        String onOff = 'on';
        if(trigger.noSend.length != _cantLast) {
          onOff = 'off';
          _recuperarAwaitAgaing();
        }

        return IndicadorCola(
          onOff: onOff,
          colorOn: const Color.fromARGB(255, 54, 74, 252),
          colorOff: Colors.white.withOpacity(0.05)
        );
      },
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
          padding: const EdgeInsets.only(right: 15, left: 5, top: 8),
          shrinkWrap: true,
          controller: _ctrScrollAwait,
          itemCount: _lstAwait.length,
          itemBuilder: (_, int i) {

            if(_proc.receiverCurrent.idReceiver == _lstAwait[i].idReceiver) {
              return const SizedBox();
            }
            
            return TileAwaitCamp(
              index: i+1,
              receiver: _lstAwait[i],
              childCheck: _childCheck(_lstAwait[i]),
            );
          }
        )
      )
    );
  }

  ///
  Widget _childCheck(ScmEntity receiver) {

    return Checkbox(
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
    );
  }


  // ----------------CONTROLADOR--------------------


  /// Recuperamos los mensajes de la campaña actual
  Future<void> _getReceptores() async {

    if(!_isInit) {
      _isInit = true;
      _proc = context.read<ProcessProvider>();
      _proc.setTituloColaBarr = 'Cargando...';
    }
    _lstAwait = [];

    await _getMap();
  }

  /// Recuperamos los mensajes de la campaña actual
  Future<void>  _recuperarAwaitAgaing() async {
    await _getMap();
    if(mounted) {
      setState(() { });
    }
  }

  /// Recuperamos los mensajes de la campaña actual
  Future<void>  _getMap() async {

    final msgs = List<String>.from(_proc.enProceso.noSend);
    if(msgs.isNotEmpty) {

      _lstAwait = await GetContentFile.getAllReceiverOfCampaings(
        filesRecivers: msgs, fileNameCurrent: _proc.currentFileReceiver
      );
      
      _cantLast = msgs.length;

      Future.microtask((){
        _proc.tituloColaBarr = '${_lstAwait.length} msg(s). Campaña Actual ID.: ${_proc.enProceso.id}';
      });
    }
  }
  
}